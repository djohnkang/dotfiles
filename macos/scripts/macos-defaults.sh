#!/bin/bash
set -euo pipefail

echo "macOS 시스템 설정을 적용합니다..."

# ============================================================
# 키보드
# ============================================================
# 키 반복 속도: 가장 빠르게 (1), 반복 지연 시간: 가장 짧게 (10)
defaults write NSGlobalDomain KeyRepeat -int 1
defaults write NSGlobalDomain InitialKeyRepeat -int 10

# 자동 완성/교정 비활성화
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false
defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false

# ============================================================
# Dock
# ============================================================
defaults write com.apple.dock tilesize -int 48
defaults write com.apple.dock show-recents -bool false
defaults write com.apple.dock minimize-to-application -bool true

# Dock 앱 초기화: 전부 비우고 유지할 앱만 다시 추가
add_dock_app() {
    defaults write com.apple.dock persistent-apps -array-add \
        "<dict><key>tile-data</key><dict><key>file-data</key><dict>\
<key>_CFURLString</key><string>$1</string>\
<key>_CFURLStringType</key><integer>0</integer>\
</dict></dict></dict>"
}

defaults write com.apple.dock persistent-apps -array
add_dock_app "/System/Applications/Safari.app"
add_dock_app "/System/Applications/Messages.app"
add_dock_app "/System/Applications/Calendar.app"
echo "  Dock 정리 완료: Safari, Messages, Calendar만 유지"

killall Dock

# ============================================================
# Finder
# ============================================================
# 새 Finder 창에서 Downloads 폴더 열기
defaults write com.apple.finder NewWindowTarget -string "PfLo"
defaults write com.apple.finder NewWindowTargetPath -string "file://${HOME}/Downloads/"
defaults write com.apple.finder ShowPathbar -bool true
defaults write com.apple.finder ShowStatusBar -bool true
killall Finder

# ============================================================
# 스크린샷
# ============================================================
defaults write com.apple.screencapture location -string "${HOME}/Screenshots"
mkdir -p "${HOME}/Screenshots"

echo "macOS 시스템 설정 적용 완료!"
