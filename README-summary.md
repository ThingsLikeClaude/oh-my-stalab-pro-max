# oh-my-stalab-pro-max — Summary

9-Phase 자율 개발 파이프라인. Plan까지 사용자 관여 → 이후 완전 자율 코딩+검증.

## 한눈에 보기

- **커맨드**: `/oms-pro-max "기능 설명"`
- **Phase 0~3**: Interview → PRD → Plan (사용자 리뷰)
- **Phase 4~8**: Design → Test → Implement → Verify → Improve (자율)
- **Ralph 루프**: 검증-개선 최대 10회 자동 반복
- **학습**: 성공/실패 패턴 축적 → 다음 실행 최적화

## 설치

```bash
# 전제: harness + bkit 먼저 설치
git clone https://github.com/ThingsLikeClaude/oh-my-stalab-pro-max.git
cd oh-my-stalab-pro-max && bash install.sh
```

## 의존성

- [oh-my-stalab-harness](https://github.com/ThingsLikeClaude/oh-my-stalab-harness) (글로벌)
- [bkit plugin](https://github.com/popup-studio-ai/bkit-claude-code) (`claude plugin add bkit`)

## 라이선스

MIT
