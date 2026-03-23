# oh-my-stalab-pro-max

자율 실행 풀사이클 개발 파이프라인. 기능 설명 한 줄로 Interview → PRD → Plan → Design → Test → Implement → Verify → Improve까지 자동 진행.

## 아키텍처

```
Layer 1: oh-my-stalab Harness (글로벌 ~/.claude/)
  → 10 agents, 14 commands, 12 hooks, 13 skills, 6 rules

Layer 2: oh-my-stalab-pro-max (프로젝트 레벨 .claude/)
  → 3 agents, 1 command (파이프라인 전용)

Layer 3: bkit plugin (PDCA 자동화)
  → gap-detector, pdca-iterator, report-generator
```

## 전제조건

1. **Claude Code** v2.1.71+
2. **oh-my-stalab Harness** — 글로벌 설치 완료 (`~/.claude/agents/`, `commands/`, `hooks/`, `skills/`, `rules/`)
3. **bkit plugin** — 설치 필수:
   ```bash
   claude plugin add bkit
   ```
   또는 [bkit-claude-code](https://github.com/popup-studio-ai/bkit-claude-code) 참고

## 설치

### 전제조건 (먼저 설치)
```bash
# 1. oh-my-stalab-harness (글로벌 베이스)
git clone https://github.com/ThingsLikeClaude/oh-my-stalab-harness.git
cd oh-my-stalab-harness && bash install.sh

# 2. bkit plugin
claude plugin add bkit
```

### pro-max 설치 (글로벌)
```bash
git clone https://github.com/ThingsLikeClaude/oh-my-stalab-pro-max.git
cd oh-my-stalab-pro-max
bash install.sh
```

`~/.claude/`에 글로벌 설치됩니다. 모든 프로젝트에서 `/oms-pro-max` 사용 가능.
`.pipeline/`은 실행한 프로젝트 디렉토리에 자동 생성됩니다.

## 사용법

```bash
/oms-pro-max "OAuth 기반 사용자 인증 시스템"
```

### 실행 흐름

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

### 중단 후 재개
```bash
/oms-pro-max --resume
```

## 산출물

실행 후 `.pipeline/` 디렉토리 생성:

```
.pipeline/
├── state.json              # 진행 상태
├── interviews/             # Phase 0
├── prd/                    # Phase 1-2
├── plans/                  # Phase 3 (3개 대안)
├── design/                 # Phase 4
├── reports/                # Phase 7-8 검증 + 최종
├── memory/                 # 학습 데이터 (실행 간 유지)
│   └── learnings.json
└── logs/                   # 실행 로그
```

## 학습 시스템

매 실행의 성공/실패 패턴을 `.pipeline/memory/learnings.json`에 축적합니다.

다음 실행 시 자동으로 과거 패턴을 주입:
- **Design**: 과거 설계-구현 괴리 패턴 반영
- **Test**: 과거 실패 패턴에 대한 방어 테스트 추가
- **Implement**: 과거 타입 에러 패턴 회피
- **Improve**: 과거 수정 패턴 우선 적용

## 글로벌 에이전트 의존성

oh-my-stalab-pro-max가 참조하는 oh-my-stalab Harness 에이전트:

| 에이전트 | 사용 Phase |
|---------|-----------|
| code-architect | 3, 4, 6 |
| tdd-guide | 5 |
| code-reviewer | 7 |
| build-error-resolver | 8 |
| code-simplifier | 8 |

## bkit 에이전트 의존성

| 에이전트 | 사용 Phase |
|---------|-----------|
| bkit:gap-detector | 7 (gap analysis) |
| bkit:pdca-iterator | 8 (auto-improvement) |
| bkit:report-generator | 완료 (리포트) |

## 커스터마이징

### Ralph 반복 횟수 변경
`.pipeline/state.json`의 `ralph.maxIterations`를 수정.

### Phase 건너뛰기
이미 PRD가 있는 경우, `.pipeline/prd/` 에 문서를 미리 넣고 state.json에서 해당 phase를 `completed`로 설정.

### .gitignore 권장
```
.pipeline/state.json
.pipeline/logs/
# memory/는 유지 (학습 데이터)
```

## 티어 시스템

| 티어 | 모델 | 용도 |
|------|------|------|
| THOROUGH | opus | 계획, 설계, 검증 판정 |
| STANDARD | sonnet | 구현, 테스트, 수정 |
| LOW | haiku | 탐색, 빠른 검색 |

## 라이선스

MIT
