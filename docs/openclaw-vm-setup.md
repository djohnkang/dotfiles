# OpenClaw VM Setup Guide

UTM + Ubuntu Linux VM에서 OpenClaw을 격리 실행하는 가이드.

## Prerequisites (Host macOS)

- UTM 설치: `brew install --cask utm`
- Ubuntu Server ISO 다운로드: https://ubuntu.com/download/server

## VM 생성 (UTM)

1. UTM > Create a New Virtual Machine > Virtualize > Linux
2. 설정:
   - RAM: 4GB
   - CPU: 2 cores
   - Disk: 20GB
   - Network: Shared Network (NAT)
3. Ubuntu Server ISO 마운트 후 설치

## VM 내부 셋업

```bash
# 시스템 업데이트
sudo apt update && sudo apt upgrade -y

# Node.js 22 설치 (nvm)
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.0/install.sh | bash
source ~/.bashrc
nvm install 22
nvm use 22

# pnpm 설치
npm install -g pnpm

# Chrome headless 설치 (브라우저 자동화용)
sudo apt install -y chromium-browser

# OpenClaw 설치
npm install -g openclaw@latest

# 온보딩 (interactive wizard)
openclaw onboard --install-daemon
```

## 보안 하드닝

```bash
# Gateway를 localhost에만 바인딩
openclaw doctor --fix

# 보안 감사
openclaw doctor
```

### 설정 파일 (`~/.openclaw/config.json`)

```json
{
  "gateway": {
    "host": "127.0.0.1",
    "port": 18789,
    "auth": {
      "token": "<random-32char-token>"
    }
  },
  "agents": {
    "defaults": {
      "tools": {
        "blocked": ["exec", "browser", "web_fetch", "nodes", "cron"]
      }
    }
  }
}
```

필요한 도구만 개별적으로 허용:
```bash
openclaw config set agents.defaults.tools.allowed '["send", "memory", "calendar"]'
```

## 주의사항

- [ ] 버너 계정 사용 (메인 이메일/메시징 계정 연결 금지)
- [ ] API 키는 환경변수로 관리 (`export ANTHROPIC_API_KEY=...`)
- [ ] 최신 버전 유지: `npm update -g openclaw`
- [ ] 정기적으로 `openclaw doctor` 실행
- [ ] WhatsApp 연결 시 계정 밴 리스크 인지
