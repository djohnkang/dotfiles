# Dotfiles Project Context

## Overview

macOS 개발 환경 자동화 dotfiles 저장소 (`~/dotfiles/`).
여러 머신(personal, work, openclaw, VM 등)에서 공통 설정을 관리하고, 머신별 설정은 `*.local` 파일과 `machines/` 디렉토리로 분리.

**Repo**: https://github.com/djohnkang/dotfiles
**User**: John Kang (djohnkang@gmail.com)

## Architecture

### Tooling
- **GNU Stow**: 심볼릭 링크 기반 dotfile 관리 (`stow zsh git` → `~/.zshrc`, `~/.gitconfig`)
- **hidutil + LaunchAgent**: Karabiner 없이 키보드 리매핑 (Right Command → F18, Caps Lock → Ctrl)
- **activateSettings -u**: 키보드 단축키 변경 즉시 반영 (재로그인 불필요)

### install.sh 실행 순서
1. Homebrew 설치 + PATH 로드 (Apple Silicon / Intel 대응)
2. macOS 시스템 설정 (Dock, 키보드, Finder, 스크린샷)
3. 키보드 리매핑 (Right Command → F18 한/영, Caps Lock → Ctrl, 입력 소스 전환 단축키)
4. Homebrew 패키지 설치 (Brewfile → Brewfile.arm64 → stow)
5. Mac App Store 앱 설치 (Brewfile.mas, Apple ID 로그인 체크)

### Brewfile 분리 전략
| 파일 | 조건 | 내용 |
|------|------|------|
| `Brewfile` | 항상 | 공통 brew/cask 패키지 |
| `Brewfile.arm64` | `uname -m == arm64` | arm64 전용 cask (Dia, ChatGPT, ChatGPT Atlas) |
| `Brewfile.mas` | Apple ID 로그인 시 | Mac App Store 앱 (별도 confirm) |

### 머신별 설정
- `~/.zshrc.local` / `~/.gitconfig.local`: gitignore 대상, 머신별 오버라이드
- `machines/` 디렉토리: personal, work, openclaw (향후 확장)

## Key Design Decisions

### Dock 관리
- **PlistBuddy 직접 조작 실패**: cfprefsd 캐시와 충돌하여 일부 머신에서 미적용
- **로컬라이즈 이슈**: 한국어 macOS에서 file-label이 한국어로 저장되어 영어 이름 매칭 실패
- **최종 방식**: `defaults write com.apple.dock persistent-apps -array`로 전체 초기화 후 `add_dock_app()` 함수로 원하는 앱만 추가 (현재: Messages, Calendar만 유지)

### 키보드 한/영 전환
- `defaults write com.apple.symbolichotkeys.plist` 단독으로는 적용 안 됨
- **`activateSettings -u`** 호출 필수 (Private Framework, macOS Catalina~Sequoia 동작 확인)
- fallback: activateSettings 없으면 `open "x-apple.systempreferences:com.apple.Keyboard"` 로 설정 화면 오픈 + 가이드 출력

### Finder 사이드바 즐겨찾기
- macOS가 `sfl3` (NSSecureCoding 바이너리) 포맷으로 관리 → 자동화 불가
- `docs/manual-setup.md`에 수동 설정 체크리스트로 관리

### Homebrew 설치 직후 PATH
- 새 머신에서 brew 설치 후 현재 셸에 PATH가 안 잡히는 문제 발생
- 스크립트 시작 시 + 설치 직후 양쪽에서 `brew shellenv` 실행으로 해결

## File Structure

```
~/dotfiles/
├── CLAUDE.md                        # 이 파일
├── README.md                        # 사용자 문서
├── install.sh                       # 부트스트랩 (interactive, 멱등성)
├── Brewfile                         # 공통 패키지
├── Brewfile.arm64                   # Apple Silicon 전용
├── Brewfile.mas                     # Mac App Store (Apple ID 필요)
├── .gitignore                       # *.local, .DS_Store
├── docs/
│   └── manual-setup.md              # 자동화 불가 수동 설정 체크리스트
├── zsh/.zshrc                       # stow → ~/.zshrc
├── git/.gitconfig                   # stow → ~/.gitconfig
├── macos/scripts/
│   └── macos-defaults.sh            # Dock, 키보드, Finder, 스크린샷
├── keyboard/scripts/
│   └── setup-keyboard.sh            # hidutil + LaunchAgent + F18 단축키
└── machines/                        # 머신별 오버라이드 (향후)
    ├── personal/
    ├── work/
    └── openclaw/
```

## Conventions

- 스크립트는 `set -euo pipefail` 사용
- 각 단계마다 `confirm()` 으로 y/n 확인 (interactive mode)
- 성공: `info()` (`[✓]`), 경고/스킵: `warn()` (`[!]`)
- 자동화 불가 항목은 `docs/manual-setup.md`에 체크리스트로 관리
- 커밋 메시지: 영문 제목 + 한국어 본문 설명

## Current Status / Next Steps

- [x] Phase 1: 공통 bare minimum (zsh, git, Brewfile, macOS defaults, keyboard)
- [ ] OpenClaw 머신 설정 (`machines/openclaw/`): 보안 리서치 진행 중
  - CLI + macOS 앱 설치, Chrome/Chromium, pnpm 포함 예정
  - 보안 이슈 검토 후 스크립팅 진행
- [ ] Phase 2: 머신별 분기 (`machines/personal/`, `machines/work/`)
- [ ] Phase 3+: IDE, 터미널, Raycast 등 설정

## Known Issues

- `install.sh` 91~97행에 stow 블록이 중복 else/warn 구조로 보임 (패키지 설치 스킵 시 stow도 함께 스킵되는 것이 의도)
