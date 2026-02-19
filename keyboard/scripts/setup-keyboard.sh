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

echo ""
echo "Right Command → F18 매핑 완료!"
echo ""
echo "남은 수동 설정:"
echo "  시스템 설정 > 키보드 > 키보드 단축키 > 입력 소스"
echo "  → '입력 소스 전환' 단축키를 F18로 지정하세요."
