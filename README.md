# dotfiles
[![GitHub release](https://img.shields.io/github/release/nogikun/dotfiles)](https://github.com/nogikun/dotfiles/releases)
[![Docs](https://img.shields.io/badge/Docs--0D1117?logo=github&logoColor=0D1117f&style=flat)](https://github.com/nogikun/dotfiles/wiki)
<!-- 
リリースしたら：
[![GitHub release](https://img.shields.io/github/release/nogikun/dotfiles)](https://github.com/nogikun/dotfiles/releases)
タグなら：
[![GitHub tag (latest SemVer)](https://img.shields.io/github/v/tag/nogikun/dotfiles?sort=semver)](https://github.com/nogikun/dotfiles/tags)
-->

自身が利用する環境ファイルをこちらで管理する。  
このリポジトリは、 `~` 直下に配置するようにしてください。

## 📦 Included Configurations

以下の設定ファイルが含まれています。

- **zsh**: Oh My Zsh をベースとした設定 (macOS / Linux)
- **PowerShell**: oh-my-posh をベースとした設定 (Windows)
- **WezTerm**: ターミナルエミュレータの設定
- **Coding Agents**: AIコーディングエージェント用の設定

## 🚀 Getting started

### 1. Install tools

必要なツール等をインストールする。

■ Linux

```sh
sudo apt install stow
```

■ macOS

```sh
brew install stow
```

■ Windows

stow は不要。PowerShell 7 (pwsh) と oh-my-posh を用意する。

```powershell
winget install Microsoft.PowerShell -s winget
winget install JanDeDobbeleer.OhMyPosh -s winget
```

あわせて、プロンプトのアイコンを表示するために [Nerd Font](https://www.nerdfonts.com/) をインストールし、
ターミナル (Windows Terminal など) のフォントに設定してください。

### 2. Run setup.sh

自身のOSに従って任意のシェルスクリプトを実行する。

■ Linuxの場合

```sh
cd linux
chmod +x setup.sh
./setup.sh
```

■ macOSの場合

```sh
cd macos
chmod +x setup.sh
./setup.sh
```

■ Windowsの場合

PowerShell 7 (pwsh) で実行する。`oh-my-posh` が未インストールの場合は、
スクリプト内で winget によるインストールを確認されます。

```powershell
cd windows
pwsh -File .\setup.ps1
```

`$PROFILE` からリポジトリ内のプロファイルへシンボリックリンクを張ります。
シンボリックリンクの作成には開発者モード (もしくは管理者権限) が必要で、
利用できない場合は代わりに dot-source するスタブが書き出されます。

プロンプトのテーマは macOS の `heapbytes-mac` (Oh My Zsh) の見た目を
oh-my-posh へ移植した `windows/ohmyposh/heapbytes-mac.omp.json` を使用します。

```
╭─[ ~/dotfiles] [ 192.168.1.5] ( main) ( .venv) ( dotfiles)
╰─▶
```
