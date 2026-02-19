#!/bin/bash
set -euo pipefail

echo "macOS 시스템 설정을 적용합니다..."

# ============================================================
# 키보드
# ============================================================
defaults write NSGlobalDomain KeyRepeat -int 2
defaults write NSGlobalDomain InitialKeyRepeat -int 15

# 자동 완성/교정 비활성화
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false
defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false

# ============================================================
# Dock
# ============================================================
defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock tilesize -int 48
defaults write com.apple.dock show-recents -bool false
defaults write com.apple.dock minimize-to-application -bool true

# Dock 앱 배치 (dockutil 필요)
if command -v dockutil &>/dev/null; then
    dockutil --remove all --no-restart
    dockutil --add /Applications/Brave\ Browser.app --no-restart
    dockutil --add /Applications/iTerm.app --no-restart
    dockutil --add /Applications/Cursor.app --no-restart
    dockutil --add /Applications/Slack.app --no-restart
    dockutil --add /Applications/Spark.app --no-restart
    dockutil --add /System/Applications/System\ Settings.app --no-restart
else
    echo "경고: dockutil이 설치되어 있지 않습니다. Dock 앱 배치를 건너뜁니다."
fi

killall Dock

# ============================================================
# Finder
# ============================================================
defaults write com.apple.finder ShowPathbar -bool true
defaults write com.apple.finder ShowStatusBar -bool true
killall Finder

# ============================================================
# 스크린샷
# ============================================================
defaults write com.apple.screencapture location -string "${HOME}/Screenshots"
mkdir -p "${HOME}/Screenshots"

echo "macOS 시스템 설정 적용 완료!"
