# dotfiles

macOS 개발 환경 설정을 자동화하는 dotfiles 저장소.

## 빠른 시작

```bash
git clone https://github.com/djohnkang/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh
```

## 구조

```
~/dotfiles/
├── install.sh              # 부트스트랩 스크립트
├── Brewfile                # 공통 Homebrew 패키지
├── zsh/.zshrc              # Shell 설정 (stow)
├── git/.gitconfig          # Git 설정 (stow)
├── macos/scripts/          # macOS 시스템 설정
├── keyboard/scripts/       # 한/영 전환 설정
└── machines/               # 머신별 오버라이드 (향후)
```

## 도구

- **GNU Stow**: 심볼릭 링크 기반 dotfile 관리
- **hidutil + LaunchAgent**: Karabiner 없이 Right Command → 한/영 전환

## 머신별 설정

공통 설정은 이 저장소에서 관리하고, 머신별 설정은 `*.local` 파일에 추가:

- `~/.zshrc.local` — 머신별 shell 설정 (PATH, alias 등)
- `~/.gitconfig.local` — 머신별 git 설정 (includeIf 등)

`*.local` 파일은 `.gitignore`에 포함되어 추적되지 않음.

## 수동 설정

`install.sh` 실행 후 수동 설정 항목은 [docs/manual-setup.md](docs/manual-setup.md) 참고.
