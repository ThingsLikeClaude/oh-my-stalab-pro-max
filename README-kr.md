# oh-my-stalab-pro-max

### 자율 실행 풀사이클 개발 파이프라인 (Autonomous Full-Cycle Pipeline)

> **한 줄 요약**: `/oms-pro-max "기능 설명"` 한마디면 AI가 인터뷰 → PRD → 설계 → 테스트 →
> 구현 → 검증까지 자동으로 진행합니다. Plan까지만 사용자가 관여하고, 이후는 완전 자율.

oh-my-stalab-pro-max는 [oh-my-stalab-harness](https://github.com/ThingsLikeClaude/oh-my-stalab-harness)의
도구들을 **9-Phase 파이프라인**으로 조합한 자율 실행 엔진입니다.

> Plan까지 같이 세우고, 나머지는 AI가 끝까지 한다.

---

## 목차

- [누구를 위한 도구인가요?](#누구를-위한-도구인가요)
- [아키텍처](#아키텍처)
- [설치](#설치)
- [첫 번째 사용: 5분 체험](#첫-번째-사용-5분-체험)
- [9-Phase 파이프라인 완전 가이드](#9-phase-파이프라인-완전-가이드)
- [Ralph 루프 (자동 검증-개선)](#ralph-루프-자동-검증-개선)
- [학습 시스템](#학습-시스템)
- [3개 에이전트 상세](#3개-에이전트-상세)
- [티어 시스템](#티어-시스템)
- [의존성 맵](#의존성-맵)
- [산출물 (.pipeline/)](#산출물-pipeline)
- [추천 워크플로우](#추천-워크플로우)
- [문제가 생겼을 때](#문제가-생겼을-때)
- [커스터마이징](#커스터마이징)
- [자주 묻는 질문](#자주-묻는-질문)
- [기여하기](#기여하기)

---

## 누구를 위한 도구인가요?

| 사용자 유형 | pro-max가 도와주는 방법 |
|------------|------------------------|
| **1인 개발자** | 기획부터 구현까지 혼자 하기 힘든 전체 사이클을 AI가 자동 실행 |
| **프로토타이핑** | "이런 기능 만들어줘" 한 줄이면 PRD → 설계 → 구현 → 테스트까지 |
| **TDD 실천자** | Phase 5에서 자동으로 실패 테스트 생성 → Phase 6에서 통과 코드 작성 |
| **코드 품질 중시** | Ralph 루프가 검증 5개 (테스트, 린터, 타입, 리뷰, 갭분석) 통과까지 반복 |

---

## 아키텍처

일상적인 비유로 설명하면:

**영화 제작에 비유하면**, pro-max는 영화 제작 프로세스입니다.

1. **Phase 0-3** = **프리프로덕션**: 감독(사용자)과 시나리오 작가(AI)가 함께 대본을 완성합니다.
   감독이 "이 버전으로 가자"라고 결정하면...
2. **Phase 4-8** = **프로덕션 + 포스트프로덕션**: 촬영팀, 편집팀, 음향팀이 알아서 촬영하고
   편집하고 색보정합니다. 감독은 끝날 때까지 기다리면 됩니다.
3. **Ralph 루프** = **시사회 + 재편집**: 시사회에서 문제가 발견되면 자동으로 수정하고 다시
   시사회를 반복합니다. 최대 10번.

기술적으로:

```
Layer 1: oh-my-stalab-harness (글로벌 ~/.claude/)
  → 10 에이전트, 14 커맨드, 12 훅, 13 스킬, 6 규칙
  → 이미 설치된 개별 도구들

Layer 2: oh-my-stalab-pro-max (글로벌 ~/.claude/ 확장)
  → 3 에이전트, 1 커맨드 (파이프라인 전용)
  → harness의 도구들을 9-Phase로 조합

Layer 3: bkit 플러그인 (PDCA 자동화)
  → gap-detector, pdca-iterator, report-generator
  → Phase 7-8에서 검증-개선 자동화
```

---

## 설치

### 전제조건 (순서대로 설치)

#### 1. oh-my-stalab-harness (필수 — 글로벌 베이스)

```bash
git clone https://github.com/ThingsLikeClaude/oh-my-stalab-harness.git
cd oh-my-stalab-harness && bash install.sh    # macOS/Linux
# 또는
.\install.ps1    # Windows
```

#### 2. bkit 플러그인 (필수 — PDCA 자동화)

```bash
claude plugin add bkit
```

또는 [bkit-claude-code](https://github.com/popup-studio-ai/bkit-claude-code) 참고.

#### 3. pro-max 설치

```bash
git clone https://github.com/ThingsLikeClaude/oh-my-stalab-pro-max.git
cd oh-my-stalab-pro-max && bash install.sh
```

`~/.claude/`에 글로벌 설치됩니다. **모든 프로젝트**에서 `/oms-pro-max` 사용 가능.

> **참고**: `.pipeline/`은 `/oms-pro-max`를 실행한 프로젝트 디렉토리에 자동 생성됩니다.

### 업데이트

```bash
cd oh-my-stalab-pro-max && git pull
# macOS/Linux: 심링크가 자동 반영
# Windows: bash install.sh 재실행
```

---

## 첫 번째 사용: 5분 체험

아무 프로젝트 폴더에서:

```
/oms-pro-max "간단한 todo 앱 만들어줘"
```

**Phase 0**: AI가 질문합니다 — "CLI 앱인가요 웹 앱인가요?", "데이터 저장은 파일? DB?"
→ 답변하면 인터뷰 문서 생성

**Phase 1**: 핵심 기능 PRD 생성 → "이 PRD 괜찮으세요?" → 승인

**Phase 2**: 세부 PRD + 유저 플로우 → "확인해주세요" → 승인

**Phase 3**: 3가지 구현 계획 제시 → "2번으로 해주세요" → **자율 모드 진입**

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Plan 2번 선택됨. 자율 모드로 전환합니다.
Phase 4(설계) → 5(테스트) → 6(구현) → 7↔8(검증-개선)
완료까지 자동으로 진행합니다.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

이후 Phase 4~8이 자동으로 실행됩니다. 완료되면 리포트가 나옵니다.

---

## 9-Phase 파이프라인 완전 가이드

### Phase 0: Deep Interview (사용자 관여)

**역할**: 요구사항 발굴
**도구**: deep-interview 스킬 (harness)
**방식**: 소크라테스식 1:1 질문. 한 번에 하나씩, 모든 분기를 끝까지 파고듦.

**산출물**: `.pipeline/interviews/interview-{slug}.md`

---

### Phase 1: PRD 핵심 (사용자 관여)

**역할**: 핵심 기능 정의
**도구**: pm-agent (opus)
**생성 내용**:
- Problem Statement (어떤 문제를 해결하는가)
- User Stories (사용자 시나리오)
- Functional Requirements (기능 요구사항, FR-001~)
- Non-Functional Requirements (성능, 보안)
- Out of Scope (범위 밖)
- Success Metrics (성공 지표)

**산출물**: `.pipeline/prd/prd-core-{slug}.md`
**체크포인트**: 사용자 리뷰 + 승인

---

### Phase 2: PRD 상세 + 유저 플로우 (사용자 관여)

**역할**: 엣지 케이스, 데이터 모델, API, 상태 전이 정의
**도구**: pm-agent (opus)

**산출물**:
- `.pipeline/prd/prd-detail-{slug}.md`
- `.pipeline/prd/user-flows-{slug}.md`

**체크포인트**: 사용자 리뷰 + 승인

---

### Phase 3: Plan — 3가지 대안 (사용자 관여)

**역할**: 구현 계획 수립
**도구**: code-architect (harness, opus)
**방식**: 정확히 3가지 대안 생성, 각각 장단점 분석

**산출물**:
- `.pipeline/plans/plan-{slug}-1.md`
- `.pipeline/plans/plan-{slug}-2.md`
- `.pipeline/plans/plan-{slug}-3.md`

**체크포인트**: 사용자가 1안 선택 → **자율 모드 진입**

---

### ═══ 여기서부터 완전 자율 ═══

---

### Phase 4: Design (자율)

**역할**: 상세 아키텍처 설계
**도구**: code-architect (harness, opus)
**생성 내용**: 시스템 아키텍처, 컴포넌트 분해, 데이터 플로우, API 스키마, DB 스키마, 에러 처리

**학습 주입**: 과거 `design_gap` 패턴이 있으면 명시적으로 반영

**산출물**: `.pipeline/design/design-{slug}.md`

---

### Phase 5: Test — TDD RED (자율)

**역할**: 실패하는 테스트 코드 작성
**도구**: test-designer (pro-max, sonnet) + tdd-guide (harness)
**방식**: PRD의 모든 요구사항(FR-xxx) → 테스트 케이스 매핑 → 실패하는 테스트 코드 생성

**학습 주입**: 과거 `test_failure` 패턴에 대한 방어 테스트 추가

---

### Phase 6: Implement (자율)

**역할**: 테스트를 통과하는 코드 구현
**도구**: code-architect + 서브에이전트 (harness, sonnet)
**목표**: 모든 테스트 통과 (TDD GREEN)

**학습 주입**: 과거 `type_error` 패턴 회피

---

### Phase 7: Verify (자율 — Ralph 루프 진입)

**역할**: 5가지 병렬 검증
**도구**: verification-orchestrator (pro-max, opus)

| 검증 | 도구 | 통과 기준 |
|------|------|----------|
| 테스트 | `npm test` | 전체 통과 |
| 린터 | `eslint` | 에러 0개 |
| 타입 | `tsc --noEmit` | 에러 0개 |
| 코드 리뷰 | code-reviewer (harness) | CRITICAL/HIGH 0개 |
| 갭 분석 | bkit:gap-detector | 매치율 90%+ |

**전체 통과** → 완료 리포트
**하나라도 실패** → Phase 8

---

### Phase 8: Improve (자율 — Ralph 루프)

**역할**: 실패 항목 자동 수정
**도구**: build-error-resolver + code-simplifier (harness) + bkit:pdca-iterator
**우선순위**: 타입 에러 → 테스트 실패 → 린터 → 코드 리뷰 → 설계 갭

**학습 주입**: 과거 수정 패턴 우선 적용

수정 완료 → Phase 7 재실행

---

## Ralph 루프 (자동 검증-개선)

```
Phase 7 (검증)
    ↓ 통과? → 완료 리포트
    ↓ 실패? ↴
Phase 8 (개선)
    ↓ 수정 완료
    ↓
Phase 7 (재검증)
    ↓ 통과? → 완료 리포트
    ↓ 실패? ↴
Phase 8 (재개선)
    ...최대 10회 반복...
```

### 에스컬레이션 규칙

| 상황 | 대응 |
|------|------|
| 같은 실패 3회 연속 | "아키텍처 변경 필요" 표시, 다른 접근 시도 |
| 5회 이상 반복 | 범위 축소 — 핵심 기능만 집중 |
| 8회 이상 반복 | 스코프 리덕션 제안 |
| 10회 도달 | 중단 + 실패 리포트 (어디서 막혔는지 상세 기록) |

---

## 학습 시스템

일상적인 비유: **의사의 진료 기록**입니다. 이 환자(프로젝트)에서 어떤 치료(수정)가
효과가 있었고, 어떤 부작용(실패)이 반복되었는지 기록합니다. 다음 진료(실행) 때
이 기록을 참고하여 더 빠르게 치료합니다.

### 저장 위치

`.pipeline/memory/learnings.json` — 프로젝트별, 실행 간 유지

### 학습 흐름

```
1. Phase 7에서 검증 실패
   → 실패 유형 분류: test_failure, type_error, lint_violation, design_gap

2. Phase 8에서 수정
   → 기록: { what_failed, why_failed, how_fixed }

3. Ralph 루프 완료 후
   → 자동 회고: 반복 횟수, 실패 유형 분포, 교훈 추출
   → learnings.json에 추가

4. 다음 /oms-pro-max 실행 시
   → Phase 4 (Design): 과거 design_gap 패턴 반영
   → Phase 5 (Test): 과거 failure 패턴에 방어 테스트 추가
   → Phase 6 (Implement): 과거 type_error 패턴 회피
   → Phase 8 (Improve): 과거 수정 패턴 우선 적용
```

### 예시

```json
{
  "id": "L001",
  "type": "failure_pattern",
  "category": "type_error",
  "description": "Optional 타입 체크 누락으로 런타임 에러",
  "solution": "strict null check + early return 패턴 적용",
  "frequency": 3,
  "lastSeen": "2026-03-23"
}
```

3번째 실행부터는 Phase 6에서 Optional 타입을 만나면 자동으로 null check를 추가합니다.

---

## 3개 에이전트 상세

### pm-agent — 제품 요구사항 전문가 (Opus)

**역할**: Phase 1-2에서 PRD 생성
**비유**: 시나리오 작가. 감독(사용자)의 아이디어를 구체적인 대본으로 만드는 사람.

**Phase 1 산출물**: 핵심 PRD (Problem, User Stories, FR, NFR, Out of Scope, Metrics)
**Phase 2 산출물**: 세부 PRD (Edge Cases, Data Model, API, State Transitions) + 유저 플로우

코드베이스를 먼저 분석하여 기존 패턴에 맞는 요구사항을 생성합니다.
`[TBD]` 마커로 불확실한 부분을 명시합니다.

### test-designer — 테스트 설계 전문가 (Sonnet)

**역할**: Phase 5에서 실패하는 테스트 코드 작성
**비유**: 시험 출제자. 정답(구현)이 나오기 전에 시험지(테스트)를 먼저 만드는 사람.

**테스트 커버리지**:
- Happy Path (정상 흐름)
- Edge Cases (경계값, 빈 입력, 최대값)
- Error Paths (잘못된 입력, 네트워크 실패, 권한 없음)
- State Transitions (상태 변화)
- Integration (API 계약, DB 연동)
- Regression (과거 실패 패턴 방어)

프로젝트의 테스트 프레임워크(Jest, Vitest, pytest 등)를 자동 감지합니다.

### verification-orchestrator — 검증 지휘관 (Opus)

**역할**: Phase 7에서 5개 검증을 병렬 실행하고 pass/fail 판정
**비유**: 품질 관리 팀장. 5개 검사팀(테스트, 린터, 타입, 리뷰, 갭분석)을 동시에
보내고, 결과를 종합하여 출하(배포) 가능 여부를 결정하는 사람.

**병렬 실행**: Agent tool로 code-reviewer + gap-detector를 서브에이전트로,
Bash로 npm test + eslint + tsc를 동시 실행.

**에스컬레이션**: 같은 실패가 3회 반복되면 "아키텍처 변경 필요"로 에스컬레이션.

---

## 티어 시스템

| 티어 | 모델 | 비유 | 사용 Phase |
|------|------|------|-----------|
| **THOROUGH** | opus | CTO | Phase 1-4 (계획, 설계), Phase 7 (검증 판정) |
| **STANDARD** | sonnet | 시니어 개발자 | Phase 5 (테스트), Phase 6 (구현), Phase 8 (수정) |
| **LOW** | haiku | 인턴 | 코드 탐색, 빠른 검색 |

고수준 판단(요구사항 분석, 아키텍처 설계, 최종 판정)은 Opus,
실행 수준 작업(테스트 작성, 코드 구현, 버그 수정)은 Sonnet을 사용합니다.

---

## 의존성 맵

```
oh-my-stalab-pro-max
  │
  ├── oh-my-stalab-harness (글로벌 ~/.claude/)
  │     ├── code-architect  ──── Phase 3, 4, 6
  │     ├── tdd-guide       ──── Phase 5
  │     ├── code-reviewer   ──── Phase 7
  │     ├── build-error-resolver ── Phase 8
  │     ├── code-simplifier ──── Phase 8
  │     └── deep-interview  ──── Phase 0
  │
  └── bkit plugin
        ├── gap-detector    ──── Phase 7 (설계-구현 갭 분석)
        ├── pdca-iterator   ──── Phase 8 (자동 개선)
        └── report-generator ─── 완료 리포트
```

---

## 산출물 (.pipeline/)

`/oms-pro-max`를 실행하면 **현재 프로젝트 디렉토리**에 자동 생성됩니다.

```
.pipeline/
├── state.json                    ← 진행 상태 (현재 Phase, 반복 횟수)
├── interviews/
│   └── interview-{slug}.md       ← Phase 0
├── prd/
│   ├── prd-core-{slug}.md        ← Phase 1
│   ├── prd-detail-{slug}.md      ← Phase 2
│   └── user-flows-{slug}.md      ← Phase 2
├── plans/
│   ├── plan-{slug}-1.md          ← Phase 3 (3개 대안)
│   ├── plan-{slug}-2.md
│   └── plan-{slug}-3.md
├── design/
│   └── design-{slug}.md          ← Phase 4
├── reports/
│   ├── verification-{slug}-1.md  ← Phase 7 (매 반복마다)
│   ├── verification-{slug}-2.md
│   └── final-{slug}.md           ← 최종 리포트
├── memory/
│   └── learnings.json            ← 학습 데이터 (실행 간 유지)
└── logs/                         ← 실행 로그
```

### .gitignore 권장

```
.pipeline/state.json
.pipeline/logs/
# memory/는 유지 — 학습 데이터가 다음 실행을 최적화합니다
```

---

## 추천 워크플로우

### 새 기능 (권장)

```
/oms-pro-max "기능 설명"
→ Phase 0-3: 인터뷰 → PRD → Plan 선택
→ Phase 4-8: 자율 실행 (완료까지 대기)
```

### 이미 PRD가 있는 경우

`.pipeline/prd/` 폴더에 PRD 파일을 미리 넣고, `state.json`에서 Phase 0-2를
`completed`로 설정하면 Phase 3부터 시작합니다.

### 중단 후 재개

```
/oms-pro-max --resume
```

`state.json`에서 마지막 완료 Phase를 읽고 이어서 진행합니다.

### 피해야 할 패턴

| 하지 마세요 | 이유 | 대신 이렇게 |
|------------|------|------------|
| 간단한 버그에 pro-max | 9-Phase는 과도한 오버헤드 | `/build-fix` (harness) |
| Phase 0-3 건너뛰기 | 부실한 요구사항 → 부실한 구현 | 인터뷰부터 시작 |
| Ralph 10회 실패 무시 | 근본적 설계 문제 | 요구사항 줄이고 재실행 |

---

## 문제가 생겼을 때

| 상황 | 해결 |
|------|------|
| Phase 0-3에서 막힘 | 질문에 최대한 구체적으로 답변 |
| Phase 6 구현이 느림 | 정상. 큰 기능은 시간이 걸림 |
| Ralph 5회 이상 반복 | 자동으로 범위 축소됨. 최종 리포트에서 원인 확인 |
| Ralph 10회 실패 | `.pipeline/reports/final-*.md`에서 원인 분석 → 요구사항 축소 후 재실행 |
| 세션 중단됨 | `/oms-pro-max --resume` |
| harness 미설치 경고 | harness 먼저 설치: `cd oh-my-stalab-harness && bash install.sh` |
| bkit 미설치 경고 | `claude plugin add bkit` |

---

## 커스터마이징

### Ralph 반복 횟수 변경

`.pipeline/state.json`의 `ralph.maxIterations`를 수정:

```json
{
  "ralph": { "iteration": 0, "maxIterations": 5 }
}
```

### Phase 건너뛰기

`state.json`에서 해당 Phase를 `"completed"`로 설정하고 산출물을 미리 넣으세요.

### 검증 항목 조절

`verification-orchestrator.md`를 수정하여 검증 항목을 추가/제거할 수 있습니다.

---

## 자주 묻는 질문

### Q: harness만 써도 되나요?

네. harness는 독립적으로 사용 가능합니다 (`/plan`, `/tdd`, `/review-pr` 등).
pro-max는 이 도구들을 파이프라인으로 조합한 확장입니다.

### Q: 비용이 얼마나 드나요?

Phase에 따라 다릅니다:
- Phase 0-4: Opus 모델 사용 (고비용이지만 1회 실행)
- Phase 5-8: 주로 Sonnet 모델 (저비용, 반복 실행)
- Ralph 루프 10회 = Phase 7 Opus 판정 10회 + Phase 8 Sonnet 수정 10회

큰 기능의 경우 전체 파이프라인에 $5~$20 정도 예상됩니다.

### Q: 학습 데이터가 프로젝트 간에 공유되나요?

아닙니다. `.pipeline/memory/`는 프로젝트별로 생성됩니다.
프로젝트 간 학습을 공유하려면 `learnings.json`을 수동으로 복사하세요.

### Q: TypeScript가 아닌 프로젝트에서도 되나요?

네. verification-orchestrator가 프로젝트 도구를 자동 감지합니다:
- TypeScript 없으면 → tsc 체크 스킵
- ESLint 없으면 → 린터 체크 스킵
- 테스트 프레임워크: Jest, Vitest, pytest 등 자동 감지

### Q: 10회 반복해도 실패하면?

실패 리포트(`.pipeline/reports/final-{slug}.md`)가 생성됩니다.
보통 원인은:
1. 요구사항이 너무 큼 → 스코프 줄이고 재실행
2. 테스트 인프라 부족 → 테스트 환경 먼저 구축
3. 순환 의존성 → 아키텍처 재설계 필요

---

## 프로젝트 구조

```
oh-my-stalab-pro-max/
├── .claude-plugin/
│   ├── plugin.json               ← 플러그인 매니페스트
│   └── marketplace.json          ← 마켓플레이스 등록
├── agents/
│   ├── pm-agent.md               ← PRD 생성 (Phase 1-2)
│   ├── test-designer.md          ← 테스트 설계 (Phase 5)
│   └── verification-orchestrator.md ← 병렬 검증 (Phase 7)
├── commands/
│   └── oms-pro-max.md            ← 파이프라인 오케스트레이터
├── rules/
│   └── response-language.md      ← 한국어 응답 규칙
├── install.sh                    ← 글로벌 설치 스크립트
├── CLAUDE.md                     ← Pipeline 규칙
├── README.md                     ← 영어 문서
├── README-kr.md                  ← 이 문서
├── README-summary.md             ← 요약본
└── LICENSE                       ← MIT
```

---

## 기여하기

1. 이 레포를 Fork
2. 기능 브랜치 생성 (`git checkout -b feat/my-feature`)
3. 커밋 (`git commit -m "feat: add my feature"`)
4. 푸시 (`git push origin feat/my-feature`)
5. PR 생성

---

## 라이선스

MIT
