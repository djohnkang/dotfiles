#!/bin/bash
set -euo pipefail

echo "Right Command → 한/영 전환 (F18) 설정을 시작합니다..."

# 1. hidutil 리매핑 스크립트 생성
sudo mkdir -p /Users/Shared/bin
sudo tee /Users/Shared/bin/userkeymapping > /dev/null << 'SCRIPT'
#!/bin/bash
hidutil property --set '{"UserKeyMapping":[{"HIDKeyboardModifierMappingSrc":0x7000000e7,"HIDKeyboardModifierMappingDst":0x70000006d}]}'
SCRIPT
sudo chmod 755 /Users/Shared/bin/userkeymapping

# 2. LaunchAgent plist 생성
sudo tee /Library/LaunchAgents/userkeymapping.plist > /dev/null << 'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>userkeymapping</string>
    <key>ProgramArguments</key>
    <array>
        <string>/Users/Shared/bin/userkeymapping</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
</dict>
</plist>
PLIST

# 3. 기존 LaunchAgent 언로드 (이미 로드된 경우)
sudo launchctl bootout system /Library/LaunchAgents/userkeymapping.plist 2>/dev/null || true

# 4. LaunchAgent 로드
sudo launchctl bootstrap system /Library/LaunchAgents/userkeymapping.plist

# 5. 즉시 적용
/Users/Shared/bin/userkeymapping

# 6. 입력 소스 전환 단축키를 F18로 설정
# AppleSymbolicHotKeys ID 61 = "Select next source in Input menu"
# parameters: (65535=non-printable, 79=F18 virtual keycode, 0=no modifiers)
defaults write com.apple.symbolichotkeys.plist AppleSymbolicHotKeys -dict-add 61 \
  "<dict>
    <key>enabled</key><true/>
    <key>value</key><dict>
      <key>type</key><string>standard</string>
      <key>parameters</key><array>
        <integer>65535</integer>
        <integer>79</integer>
        <integer>0</integer>
      </array>
    </dict>
  </dict>"

# 7. 변경 즉시 반영 (재로그인 없이)
ACTIVATE="/System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings"
if [[ -x "$ACTIVATE" ]]; then
    "$ACTIVATE" -u
    echo ""
    echo "Right Command → 한/영 전환 설정 완료!"
    echo "  - Right Command → F18 키 매핑 적용됨"
    echo "  - 입력 소스 전환 단축키 → F18 설정됨 (즉시 반영)"
else
    echo ""
    echo "Right Command → F18 키 매핑 완료!"
    echo ""
    echo "입력 소스 전환 단축키는 수동 설정이 필요합니다."
    echo "설정 화면을 열겠습니다..."
    open "x-apple.systempreferences:com.apple.Keyboard"
    echo "  → '키보드 단축키...' > '입력 소스' > F18 지정"
fi
