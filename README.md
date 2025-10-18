# dotfiles
[![GitHub tag (latest SemVer)](https://img.shields.io/github/v/tag/nogikun/dotfiles?sort=semver)](https://github.com/nogikun/dotfiles/tags)
[![Docs](https://img.shields.io/badge/Docs--0D1117?logo=github&logoColor=0D1117f&style=flat)](https://github.com/nogikun/dotfiles/wiki)
<!-- 
リリースしたら：
[![GitHub release](https://img.shields.io/github/release/nogikun/dotfiles)](https://github.com/nogikun/dotfiles/releases)
-->

自身が利用する環境ファイルをこちらで管理する。  
このリポジトリは、 `~` 直下に配置するようにしてください。

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
