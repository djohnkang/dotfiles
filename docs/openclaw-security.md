# OpenClaw Security Analysis (February 2026)

## TL;DR

OpenClaw은 강력하지만 보안 리스크가 큼. **전용 VM에서 격리하여 실행** 권장.

## Critical Vulnerabilities

### CVE-2026-25253 (CVSS 8.8) — 1-Click RCE
- 조작된 URL로 인증 토큰 탈취 → sandbox 우회 → 임의 명령 실행
- **v2026.1.29에서 패치됨** — 반드시 최신 버전 사용

### 추가 취약점
- SSRF via attachment URL hydration (GHSA-wfp2-v9c7-fh79)
- Command hijacking via unsafe PATH handling (GHSA-jqpq-mgvm-f9r6)
- Code execution via unsafe hook module path (GHSA-v6c6-vqqg-w888)

## Architecture Risks

- Gateway 데몬이 포트 18789에서 상시 실행
- 파일시스템, 쉘 실행, 브라우저 제어 — 기본 제한 없음
- Prompt injection이 구조적으로 해결 불가 (공식 문서 인정)
- 135K+ 인스턴스가 인터넷에 노출, 63%가 취약

## WhatsApp/Baileys

- Baileys는 비공식 WhatsApp API → Meta ToS 위반
- 계정 영구 밴 가능, Meta가 OpenClaw을 명시적으로 차단

## Supply Chain

- ClawHub 마켓플레이스의 ~20% (800+개) 스킬이 악성코드
- 메인테이너 1명 (Peter Steinberger, OpenAI 합류)
- npm 패키지 대상 supply chain 공격 사례 존재

## Our Mitigation: UTM + Ubuntu VM

| 항목 | 설정 |
|------|------|
| **격리** | UTM Linux VM (메인 macOS와 완전 분리) |
| **네트워크** | Gateway를 127.0.0.1에만 바인딩 |
| **계정** | 버너 계정 사용 (메인 계정 연결 금지) |
| **도구** | 고위험 도구 기본 차단, allowlist 방식 |
| **버전** | 항상 최신 버전 유지 + `openclaw doctor` 정기 실행 |
| **API 키** | 환경변수로 관리, LiteLLM proxy 권장 |

## 참고 자료

- [CrowdStrike Analysis](https://www.crowdstrike.com/en-us/blog/what-security-teams-need-to-know-about-openclaw-ai-super-agent/)
- [Trend Micro Assessment](https://www.trendmicro.com/en_us/research/26/b/what-openclaw-reveals-about-agentic-assistants.html)
- [Aikido.dev Analysis](https://www.aikido.dev/blog/why-trying-to-secure-openclaw-is-ridiculous)
- [NVD — CVE-2026-25253](https://nvd.nist.gov/vuln/detail/CVE-2026-25253)
- [OpenClaw Security Docs](https://docs.openclaw.ai/gateway/security)
