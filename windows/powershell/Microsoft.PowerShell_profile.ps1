# =============================== #
#      PowerShell Profile         #
# ------------------------------- #
# 1. dotfiles のパス解決          #
# 2. IP アドレスの取得            #
# 3. oh-my-posh の初期化          #
# 4. プロンプトへの IP の受け渡し #
# =============================== #

# Nerd Font のグリフが化けないように出力を UTF-8 に固定する
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# 1. dotfiles のパス解決 -------- #

function Resolve-DotfilesRoot {
  # 候補を順に試し、windows/ohmyposh のテーマが見つかったものを採用する
  $candidates = @()

  # a) setup.ps1 が生成したスタブ、もしくはユーザーが設定した環境変数
  if ($env:DOTFILES_DIR) { $candidates += $env:DOTFILES_DIR }

  # b) このファイルが dot-source されている場合 (windows/powershell/ から 2 階層上)
  if ($PSScriptRoot) { $candidates += (Split-Path -Parent (Split-Path -Parent $PSScriptRoot)) }

  # c) $PROFILE がシンボリックリンクの場合はリンク先から辿る
  $item = Get-Item -LiteralPath $PROFILE -Force -ErrorAction SilentlyContinue
  if ($item -and $item.LinkType -eq 'SymbolicLink' -and $item.Target) {
    $target = @($item.Target)[0]
    if (-not [System.IO.Path]::IsPathRooted($target)) {
      $target = Join-Path (Split-Path -Parent $item.FullName) $target
    }
    $candidates += (Split-Path -Parent (Split-Path -Parent (Split-Path -Parent $target)))
  }

  # d) README の想定どおり ~ 直下に置かれている場合
  $candidates += (Join-Path $HOME 'dotfiles')

  foreach ($candidate in $candidates) {
    if (-not $candidate) { continue }
    $theme = Join-Path $candidate 'windows/ohmyposh/heapbytes-mac.omp.json'
    if (Test-Path -LiteralPath $theme) { return (Resolve-Path -LiteralPath $candidate).Path }
  }

  return $null
}

$DotfilesRoot = Resolve-DotfilesRoot

# 2. IP アドレスの取得 ---------- #
# macOS の heapbytes-mac テーマの get_ip_address 相当。
# 既定ルート (0.0.0.0/0) を持つインターフェースの IPv4 アドレスを返す。

function Get-PoshNicIPv4 {
  param([System.Net.NetworkInformation.NetworkInterface]$Nic)

  $address = $Nic.GetIPProperties().UnicastAddresses |
    Where-Object { $_.Address.AddressFamily -eq 'InterNetwork' -and $_.Address.ToString() -notlike '169.254.*' } |
    Select-Object -First 1

  if ($address) { return $address.Address.ToString() }
  return $null
}

function Get-LocalIPv4Address {
  # まず .NET の API で「既定ゲートウェイを持つ稼働中の NIC」を集める。
  # NetTCPIP モジュールのロードが不要なぶん Get-NetRoute より速い (約 70ms vs 約 1s)。
  $candidates = @()
  try {
    $candidates = @(
      [System.Net.NetworkInformation.NetworkInterface]::GetAllNetworkInterfaces() |
        Where-Object {
          $_.OperationalStatus -eq 'Up' -and
          $_.NetworkInterfaceType -ne 'Loopback' -and
          $_.GetIPProperties().GatewayAddresses.Count -gt 0
        }
    )
  } catch {
    # 取得できない場合はルーティングテーブル側で判定する
  }

  # 候補が 1 つに絞れるならそれを使う
  if ($candidates.Count -eq 1) {
    $ip = Get-PoshNicIPv4 -Nic $candidates[0]
    if ($ip) { return $ip }
  }

  # VPN や仮想 NIC などで複数ある場合は、ルーティングテーブルのメトリックで決める
  try {
    $route = Get-NetRoute -DestinationPrefix '0.0.0.0/0' -ErrorAction Stop |
      Where-Object { $_.NextHop -ne '0.0.0.0' } |
      Sort-Object -Property RouteMetric, ifMetric |
      Select-Object -First 1

    if ($route) {
      $address = Get-NetIPAddress -InterfaceIndex $route.ifIndex -AddressFamily IPv4 -ErrorAction Stop |
        Where-Object { $_.IPAddress -notlike '169.254.*' } |
        Select-Object -First 1
      if ($address) { return $address.IPAddress }
    }
  } catch {
    # NetTCPIP モジュールが使えない環境では候補の先頭にフォールバックする
  }

  foreach ($nic in $candidates) {
    $ip = Get-PoshNicIPv4 -Nic $nic
    if ($ip) { return $ip }
  }

  # 取得できない場合はプロンプト側で "No IP" を表示する
  return $null
}

# プロンプト描画のたびに IP を引くと遅いので一定時間キャッシュする
$Global:PoshLocalIpCache = @{ Value = $null; FetchedAt = [datetime]::MinValue }
$Global:PoshLocalIpTtlSeconds = 30

function Update-PoshLocalIp {
  $age = ((Get-Date) - $Global:PoshLocalIpCache.FetchedAt).TotalSeconds
  if ($age -lt $Global:PoshLocalIpTtlSeconds) { return }

  $Global:PoshLocalIpCache.Value = Get-LocalIPv4Address
  $Global:PoshLocalIpCache.FetchedAt = Get-Date
}

# 3. oh-my-posh の初期化 -------- #

if (-not (Get-Command oh-my-posh -ErrorAction SilentlyContinue)) {
  Write-Host '⚠️ oh-my-posh が見つかりません。`winget install JanDeDobbeleer.OhMyPosh -s winget` を実行してください。' -ForegroundColor Yellow
} elseif (-not $DotfilesRoot) {
  Write-Host '⚠️ dotfiles のパスを解決できませんでした。環境変数 DOTFILES_DIR を設定してください。' -ForegroundColor Yellow
} else {
  $PoshTheme = Join-Path $DotfilesRoot 'windows/ohmyposh/heapbytes-mac.omp.json'
  oh-my-posh init pwsh --config $PoshTheme | Invoke-Expression
}

# 4. プロンプトへの IP の受け渡し #
# oh-my-posh はプロンプト描画前に Set-PoshContext を呼ぶので、
# ここで環境変数へ入れた値をテーマ側の {{ .Env.POSH_LOCAL_IP }} が参照する。
# 注意: init が Set-PoshContext を空の関数で定義するため、必ず init の後に上書きすること。

function Set-PoshLocalIpContext {
  Update-PoshLocalIp
  $env:POSH_LOCAL_IP = $Global:PoshLocalIpCache.Value
}

function Set-PoshContext {
  param([bool]$originalStatus)

  Set-PoshLocalIpContext
}

# oh-my-posh v29 以降は init が oh-my-posh-core モジュールとして読み込まれ、
# モジュール内の prompt は同じモジュールスコープの Set-PoshContext を呼ぶ。
# グローバル側の定義では上書きされないため、モジュールスコープにも定義する。
$PoshModule = Get-Module -Name 'oh-my-posh-core' -ErrorAction SilentlyContinue
if ($PoshModule) {
  & $PoshModule { function script:Set-PoshContext([bool]$originalStatus) { Set-PoshLocalIpContext } }
}
