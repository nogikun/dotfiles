// ~/.claude/settings.json の statusLine を、このリポジトリの statusline.js に向ける。
// settings.json のほかのキー (hooks, permissions, plugins など) はそのまま残す。
// macOS / Linux / Windows 共通: node common/claude/setup.js
const fs = require('fs');
const os = require('os');
const path = require('path');

const configDir = process.env.CLAUDE_CONFIG_DIR || path.join(os.homedir(), '.claude');
const settingsFile = path.join(configDir, 'settings.json');
// Windows でも bash / cmd どちらから実行されても通るよう、スラッシュ区切りの絶対パスにする
const script = path.join(__dirname, 'statusline.js').replace(/\\/g, '/');

let settings = {};
if (fs.existsSync(settingsFile)) {
  // 読めない JSON なら例外で止まり、settings.json は書き換えない
  settings = JSON.parse(fs.readFileSync(settingsFile, 'utf8').replace(/^﻿/, ''));
}

settings.statusLine = { type: 'command', command: `node "${script}"` };

fs.mkdirSync(configDir, { recursive: true });
fs.writeFileSync(settingsFile, JSON.stringify(settings, null, 2) + '\n');
console.log(`🔗 Claude Code statusLine -> ${script}`);
