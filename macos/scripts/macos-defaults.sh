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
defaults write com.apple.dock tilesize -int 48
defaults write com.apple.dock show-recents -bool false
defaults write com.apple.dock minimize-to-application -bool true

# Dock 기본 앱 정리 (외부 도구 없이 defaults 사용)
# 기본 Dock에서 Safari, Messages, Calendar만 남기고 나머지 제거
dock_app_path() {
    local label="$1"
    defaults read com.apple.dock persistent-apps | \
        /usr/libexec/PlistBuddy -c "Print" /dev/stdin 2>/dev/null | grep -c "$label" || true
}

# 제거할 기본 앱 목록
REMOVE_APPS=(
    "Mail"
    "Maps"
    "Photos"
    "FaceTime"
    "Contacts"
    "Reminders"
    "Notes"
    "TV"
    "Music"
    "Podcasts"
    "News"
    "Keynote"
    "Numbers"
    "Pages"
    "App Store"
    "System Preferences"
    "Freeform"
)

PLIST="$HOME/Library/Preferences/com.apple.dock.plist"
for app in "${REMOVE_APPS[@]}"; do
    # persistent-apps 배열에서 해당 앱 찾아서 제거
    idx=0
    while true; do
        entry=$(/usr/libexec/PlistBuddy -c "Print :persistent-apps:${idx}:tile-data:file-label" "$PLIST" 2>/dev/null) || break
        if [[ "$entry" == "$app" ]]; then
            /usr/libexec/PlistBuddy -c "Delete :persistent-apps:${idx}" "$PLIST"
            echo "  Dock에서 제거: $app"
            # 인덱스가 밀리므로 idx 증가하지 않음
        else
            ((idx++))
        fi
    done
done

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
