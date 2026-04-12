#!/bin/bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

# 색상 출력
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

info() { echo -e "${GREEN}[✓]${NC} $1"; }
warn() { echo -e "${YELLOW}[!]${NC} $1"; }

confirm() {
    read -rp "$1 (Y/n) " answer
    [[ -z "$answer" || "$answer" =~ ^[Yy]$ ]]
}

echo ""
echo "========================================="
echo "  dotfiles 설치 스크립트"
echo "========================================="
echo ""

# =========================================================
# 1. Homebrew PATH 확인
# =========================================================
if [[ -f /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -f /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
fi

if ! command -v brew &>/dev/null; then
    echo "Homebrew가 설치되어 있지 않습니다."
    echo "먼저 k-mac을 실행하세요: curl -fsSL djohnkang.github.io/setup.sh | bash"
    exit 1
fi

# =========================================================
# 2. Brewfile 패키지 설치
# =========================================================
if brew bundle check --file="$DOTFILES_DIR/Brewfile" &>/dev/null; then
    info "Brewfile 패키지 이미 설치됨"
else
    echo "Brewfile 패키지 설치 중..."
    brew bundle --file="$DOTFILES_DIR/Brewfile"
    info "패키지 설치 완료"
fi

# arm64 전용 cask (Apple Silicon만)
if [[ "$(uname -m)" == "arm64" ]]; then
    if brew bundle check --file="$DOTFILES_DIR/Brewfile.arm64" &>/dev/null; then
        info "arm64 패키지 이미 설치됨"
    else
        brew bundle --file="$DOTFILES_DIR/Brewfile.arm64"
        info "Apple Silicon 전용 앱 설치 완료"
    fi
fi

# =========================================================
# 3. Stow 심볼릭 링크
# =========================================================
cd "$DOTFILES_DIR"
stow -v --target="$HOME" zsh
stow -v --target="$HOME" git
stow -v --target="$HOME" starship
info "심볼릭 링크 생성 완료 (~/.zshrc, ~/.gitconfig, starship.toml)"

# =========================================================
# 4. Mac App Store 앱 (선택)
# =========================================================
if confirm "Mac App Store 앱을 설치하시겠습니까? (Apple ID 로그인 필요)"; then
    if command -v mas &>/dev/null && mas account &>/dev/null 2>&1; then
        brew bundle --file="$DOTFILES_DIR/Brewfile.mas"
        info "App Store 앱 설치 완료"
    else
        warn "mas가 없거나 Apple ID에 로그인되어 있지 않습니다."
    fi
else
    warn "App Store 앱 설치를 건너뜁니다."
fi

# =========================================================
# 완료
# =========================================================
echo ""
echo "========================================="
echo "  설치 완료!"
echo "========================================="
echo ""
echo "새 셸을 열거나 source ~/.zshrc 를 실행하세요."
echo ""
