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

# Dock 기본 앱 정리 (앱 경로로 매칭 — 언어 설정 무관)
# Safari, Messages, Calendar만 남기고 나머지 제거
REMOVE_PATHS=(
    "/System/Applications/Mail.app"
    "/System/Applications/Maps.app"
    "/System/Applications/Photos.app"
    "/System/Applications/FaceTime.app"
    "/System/Applications/Contacts.app"
    "/System/Applications/Reminders.app"
    "/System/Applications/Notes.app"
    "/System/Applications/TV.app"
    "/System/Applications/Music.app"
    "/System/Applications/Podcasts.app"
    "/System/Applications/News.app"
    "/System/Applications/Freeform.app"
    "/Applications/Keynote.app"
    "/Applications/Numbers.app"
    "/Applications/Pages.app"
    "/System/Applications/App Store.app"
    "/System/Applications/System Preferences.app"
)

PLIST="$HOME/Library/Preferences/com.apple.dock.plist"
for app_path in "${REMOVE_PATHS[@]}"; do
    idx=0
    while true; do
        entry=$(/usr/libexec/PlistBuddy -c "Print :persistent-apps:${idx}:tile-data:file-data:_CFURLString" "$PLIST" 2>/dev/null) || break
        # 경로 비교 (file:// prefix, trailing slash 등 대응)
        if [[ "$entry" == *"${app_path}"* ]]; then
            label=$(/usr/libexec/PlistBuddy -c "Print :persistent-apps:${idx}:tile-data:file-label" "$PLIST" 2>/dev/null) || label="$app_path"
            /usr/libexec/PlistBuddy -c "Delete :persistent-apps:${idx}" "$PLIST"
            echo "  Dock에서 제거: $label"
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
