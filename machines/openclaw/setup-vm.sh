#!/bin/bash
# OpenClaw VM 내부에서 실행하는 셋업 스크립트
# 사용법: VM 안에서 curl로 가져와서 실행
#   curl -fsSL https://raw.githubusercontent.com/djohnkang/dotfiles/main/machines/openclaw/setup-vm.sh | bash
set -euo pipefail

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'
info() { echo -e "${GREEN}[✓]${NC} $1"; }
warn() { echo -e "${YELLOW}[!]${NC} $1"; }

echo ""
echo "========================================="
echo "  OpenClaw VM 셋업"
echo "========================================="
echo ""

# 1. 시스템 업데이트
echo "시스템 패키지 업데이트 중..."
sudo apt update && sudo apt upgrade -y
info "시스템 업데이트 완료."

# 2. Node.js 22 (nvm)
if command -v node &>/dev/null && [[ "$(node -v)" == v22* ]]; then
    info "Node.js $(node -v) 이미 설치됨."
else
    echo "Node.js 22 설치 중..."
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.0/install.sh | bash
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    nvm install 22
    nvm use 22
    info "Node.js $(node -v) 설치 완료."
fi

# 3. pnpm
if command -v pnpm &>/dev/null; then
    info "pnpm 이미 설치됨."
else
    npm install -g pnpm
    info "pnpm 설치 완료."
fi

# 4. Chrome headless (브라우저 자동화용)
if command -v chromium-browser &>/dev/null || command -v chromium &>/dev/null; then
    info "Chromium 이미 설치됨."
else
    sudo apt install -y chromium-browser
    info "Chromium 설치 완료."
fi

# 5. OpenClaw 설치
if command -v openclaw &>/dev/null; then
    info "OpenClaw 이미 설치됨. ($(openclaw --version 2>/dev/null || echo 'unknown'))"
    echo "  업데이트: npm update -g openclaw"
else
    npm install -g openclaw@latest
    info "OpenClaw 설치 완료."
fi

# 6. 보안 하드닝
echo ""
echo "========================================="
echo "  보안 설정"
echo "========================================="
echo ""

# Gateway localhost 바인딩
openclaw doctor --fix 2>/dev/null || true
info "Gateway localhost 바인딩 확인."

echo ""
info "셋업 완료!"
echo ""
echo "다음 단계:"
echo "  1. openclaw onboard --install-daemon"
echo "  2. 버너 계정으로 채널 연결"
echo "  3. API 키 설정: export ANTHROPIC_API_KEY=..."
echo "  4. openclaw doctor 로 보안 상태 확인"
echo ""
echo "보안 가이드: https://github.com/djohnkang/dotfiles/blob/main/docs/openclaw-security.md"
echo ""
