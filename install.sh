#!/bin/bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

# 색상 출력
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

info() { echo -e "${GREEN}[✓]${NC} $1"; }
warn() { echo -e "${YELLOW}[!]${NC} $1"; }

confirm() {
    read -rp "$1 (y/n) " answer
    [[ "$answer" =~ ^[Yy]$ ]]
}

echo ""
echo "========================================="
echo "  dotfiles 설치 스크립트"
echo "========================================="
echo ""

# =========================================================
# 1. Homebrew 설치
# =========================================================
if command -v brew &>/dev/null; then
    info "Homebrew가 이미 설치되어 있습니다."
else
    if confirm "Homebrew를 설치하시겠습니까?"; then
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        # Apple Silicon Mac에서 PATH 추가
        if [[ -f /opt/homebrew/bin/brew ]]; then
            eval "$(/opt/homebrew/bin/brew shellenv)"
        fi
        info "Homebrew 설치 완료."
    else
        warn "Homebrew 설치를 건너뜁니다."
    fi
fi

# =========================================================
# 2. Homebrew 패키지 설치
# =========================================================
if command -v brew &>/dev/null; then
    if confirm "Brewfile로 공통 패키지를 설치하시겠습니까?"; then
        brew bundle --file="$DOTFILES_DIR/Brewfile"
        info "Homebrew 패키지 설치 완료."
    else
        warn "패키지 설치를 건너뜁니다."
    fi
else
    warn "Homebrew가 없어 패키지 설치를 건너뜁니다."
fi

# =========================================================
# 3. Stow로 심볼릭 링크 생성
# =========================================================
if command -v stow &>/dev/null; then
    if confirm "stow로 zsh, git 설정을 심볼릭 링크하시겠습니까?"; then
        cd "$DOTFILES_DIR"
        stow -v --target="$HOME" zsh
        stow -v --target="$HOME" git
        info "심볼릭 링크 생성 완료."
    else
        warn "심볼릭 링크 생성을 건너뜁니다."
    fi
else
    warn "stow가 설치되어 있지 않습니다. 'brew install stow' 후 다시 실행하세요."
fi

# =========================================================
# 4. macOS 시스템 설정
# =========================================================
if confirm "macOS 시스템 설정을 적용하시겠습니까? (Dock, 키보드, Finder 등)"; then
    bash "$DOTFILES_DIR/macos/scripts/macos-defaults.sh"
    info "macOS 시스템 설정 적용 완료."
else
    warn "macOS 시스템 설정을 건너뜁니다."
fi

# =========================================================
# 5. 키보드 설정 (Right Command → 한/영 전환)
# =========================================================
if confirm "Right Command → 한/영 전환 키 설정을 적용하시겠습니까? (sudo 필요)"; then
    bash "$DOTFILES_DIR/keyboard/scripts/setup-keyboard.sh"
    info "키보드 설정 완료."
else
    warn "키보드 설정을 건너뜁니다."
fi

# =========================================================
# 완료
# =========================================================
echo ""
echo "========================================="
echo "  설치 완료!"
echo "========================================="
echo ""
echo "확인 사항:"
echo "  1. 새 터미널을 열어 zsh 설정이 적용되었는지 확인하세요."
echo "  2. 'ls -la ~/.zshrc ~/.gitconfig'로 심볼릭 링크를 확인하세요."
echo "  3. 머신별 설정은 ~/.zshrc.local, ~/.gitconfig.local에 추가하세요."
echo ""
