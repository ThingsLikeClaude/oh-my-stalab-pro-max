# oh-my-stalab-pro-max

자율 실행 풀사이클 개발 파이프라인. 기능 설명 한 줄로 Interview → PRD → Plan → Design → Test → Implement → Verify → Improve까지 자동 진행.

## 아키텍처

```
Layer 1: oh-my-stalab-harness (글로벌 ~/.claude/)
  → 10 에이전트, 14 커맨드, 12 훅, 13 스킬, 6 규칙

Layer 2: oh-my-stalab-pro-max (글로벌 ~/.claude/ 확장)
  → 3 에이전트, 1 커맨드 (파이프라인 전용)

Layer 3: bkit 플러그인 (PDCA 자동화)
  → gap-detector, pdca-iterator, report-generator
```

## 설치

```bash
# 1. oh-my-stalab-harness (먼저)
git clone https://github.com/ThingsLikeClaude/oh-my-stalab-harness.git
cd oh-my-stalab-harness && bash install.sh

# 2. bkit 플러그인
claude plugin add bkit

# 3. pro-max
git clone https://github.com/ThingsLikeClaude/oh-my-stalab-pro-max.git
cd oh-my-stalab-pro-max && bash install.sh
```

모든 프로젝트에서 `/oms-pro-max` 사용 가능. `.pipeline/`은 실행한 프로젝트에 자동 생성.

## 사용법

```bash
/oms-pro-max "OAuth 기반 사용자 인증 시스템"
```

## 실행 흐름

```
━━━ 사용자 깊은 관여 (Interactive) ━━━
  Phase 0: Deep Interview → 요구사항 확정
  Phase 1: PRD 핵심 → 사용자 리뷰
  Phase 2: PRD 상세 + 유저플로우 → 사용자 리뷰
  Phase 3: Plan 3안 → 사용자 선택
━━━ "이거로 진행해" → 자율 모드 ━━━
  Phase 4: Design 자동 생성
  Phase 5: TDD 테스트 코드 작성 (RED)
  Phase 6: 구현 (GREEN)
  Phase 7↔8: 검증-개선 Ralph 루프 (최대 10회)
  → 완료 리포트 + 학습 저장
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**Phase 0~3**: 사용자와 대화하며 요구사항 확정 → Plan 선택
**Phase 4~8**: 완전 자율. 코딩, 테스트, 검증, 개선을 자동 반복

## 학습 시스템

매 실행의 성공/실패 패턴을 `.pipeline/memory/learnings.json`에 축적.
다음 실행 시 자동 주입:

- **Design**: 과거 설계-구현 괴리 패턴 반영
- **Test**: 과거 실패 패턴에 대한 방어 테스트
- **Implement**: 과거 타입 에러 패턴 회피
- **Improve**: 과거 수정 패턴 우선 적용

## 에이전트 의존성

### harness (글로벌)
| 에이전트 | Phase |
|---------|-------|
| code-architect | 3, 4, 6 |
| tdd-guide | 5 |
| code-reviewer | 7 |
| build-error-resolver | 8 |
| code-simplifier | 8 |

### bkit (플러그인)
| 에이전트 | Phase |
|---------|-------|
| gap-detector | 7 (설계-구현 갭 분석) |
| pdca-iterator | 8 (자동 개선) |
| report-generator | 완료 (리포트) |

## 산출물

```
.pipeline/
├── state.json       # 진행 상태
├── interviews/      # Phase 0
├── prd/             # Phase 1-2
├── plans/           # Phase 3 (3개 대안)
├── design/          # Phase 4
├── reports/         # Phase 7-8 검증 + 최종
├── memory/          # 학습 데이터 (실행 간 유지)
└── logs/            # 실행 로그
```

## 티어 시스템

| 티어 | 모델 | 용도 |
|------|------|------|
| THOROUGH | opus | 계획, 설계, 검증 판정 |
| STANDARD | sonnet | 구현, 테스트, 수정 |
| LOW | haiku | 탐색, 빠른 검색 |

## 요구 사항

- Claude Code v2.1.71+
- oh-my-stalab-harness 글로벌 설치
- bkit 플러그인

## 라이선스

MIT
