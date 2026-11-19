// Claude Code の statusLine。stdin で受け取った JSON から
// 「モデル名 | ctx: 使用率 | 5h: 使用率 | 7d: 使用率」を出力する。
// 使用率は 0% = 緑 → 50% = 黄 → 100% = 赤 で色付けする。
let input = '';
process.stdin.on('data', (d) => (input += d)).on('end', () => {
  const j = JSON.parse(input);
  const rate = j.rate_limits || {};

  const pct = (v) => {
    if (v == null) return '-';
    const t = Math.min(Math.max(v / 100, 0), 1);
    const r = Math.round(Math.min(255, 510 * t));
    const g = Math.round(Math.min(255, 510 * (1 - t)));
    return `\x1b[38;2;${r};${g};0m${Math.round(v)}%\x1b[0m`;
  };

  process.stdout.write([
    (j.model?.display_name || '').replace(/\s*\(.*?\)/g, ''),
    'ctx: ' + pct(j.context_window?.used_percentage),
    '5h: ' + pct(rate.five_hour?.used_percentage),
    '7d: ' + pct(rate.seven_day?.used_percentage),
  ].join(' | '));
});
