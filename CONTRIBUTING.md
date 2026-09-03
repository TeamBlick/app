# Blick App 기여 가이드

혼자 개발하더라도 모든 작업을 이슈, 작업 브랜치, Pull Request 단위로 기록합니다. 복잡한 `develop` 브랜치는 두지 않고 `main`을 중심으로 짧게 작업하는 GitHub Flow를 사용합니다.

## 기본 흐름

```text
Issue 생성
  → main 최신화
  → 작업 브랜치 생성
  → 구현 및 검증
  → Pull Request 생성
  → 체크리스트 확인
  → Squash merge
  → 작업 브랜치 삭제
```

`main`은 항상 실행 가능한 상태를 유지합니다. 기능이 덜 끝난 코드는 `main`에 직접 올리지 않고 작업 브랜치에 둡니다.

## 브랜치 전략

브랜치는 최신 `main`에서 생성합니다.

```bash
git switch main
git pull --ff-only origin main
git switch -c feat/12-map-api
```

브랜치 이름은 `<type>/<issue-number>-<short-description>` 형식을 사용합니다.

| Type | 사용 시점 | 예시 |
| --- | --- | --- |
| `feat` | 기능 추가 | `feat/9-qr-attendance` |
| `fix` | 버그 수정 | `fix/21-login-error` |
| `refactor` | 기능을 유지한 구조 개선 | `refactor/1-feature-structure` |
| `docs` | 문서 변경 | `docs/15-project-guide` |
| `test` | 테스트 추가 및 수정 | `test/18-auth-repository` |
| `chore` | 의존성 및 개발 환경 변경 | `chore/16-riverpod-setup` |
| `hotfix` | 배포 상태의 긴급 수정 | `hotfix/30-token-crash` |

- 영문 소문자와 숫자, 하이픈을 사용합니다.
- 가능하면 브랜치 하나에서 이슈 하나만 처리합니다.
- 서로 무관한 리팩터링과 기능 변경을 같은 브랜치에 섞지 않습니다.
- 작업이 끝난 브랜치는 merge 후 삭제합니다.

## 커밋 컨벤션

형식은 `Type: 작업 내용`입니다.

```text
Feat: 로그인 API 연동
Fix: refresh token 저장 오류 수정
Refactor: AuthRepository로 로그인 로직 분리
Docs: 프로젝트 실행 방법 추가
```

- Type의 첫 글자는 대문자로 작성합니다.
- 콜론 뒤에 공백 한 칸을 둡니다.
- 작업 내용은 한글로 작성합니다.
- 함수명, 클래스명, 변수명과 전문용어는 코드의 영어 표기를 유지합니다.
- 한 커밋에는 가능한 한 하나의 논리적인 변경만 포함합니다.

사용 가능한 Type은 다음과 같습니다.

| Type | 사용 시점 |
| --- | --- |
| `Feat` | 기능 추가 |
| `Fix` | 동작하지 않는 기능 수정 |
| `Refactor` | 동작을 유지하면서 구조 개선 |
| `Hotfix` | 배포 상태의 긴급 수정 |
| `Docs` | 실행에 영향을 주지 않는 문서 변경 |
| `Remove` | 파일, 폴더 또는 코드 삭제 |
| `Test` | 테스트 추가 및 수정 |
| `Chore` | 의존성, Gradle, YAML 등 개발 환경 변경 |
| `Style` | 포맷, 공백, 정렬, import 정리 |

## Pull Request 규칙

PR 제목도 커밋과 같은 `Type: 작업 내용` 형식을 사용합니다.

```text
Feat: 학생 공지사항 API 연동
```

- 관련 이슈를 `Closes #번호`로 연결합니다.
- 변경 이유와 사용자에게 보이는 동작을 설명합니다.
- 실제로 실행한 검증 항목만 체크합니다.
- 서버 미배포 등으로 확인하지 못한 내용은 참고 사항에 남깁니다.
- 기능과 무관한 파일 변경이 포함되지 않았는지 확인합니다.
- 기본 merge 방식은 `Squash and merge`를 사용합니다.
- merge 후 작업 브랜치를 삭제합니다.

혼자 개발할 때도 PR을 바로 merge하기 전에 diff를 한 번 처음부터 읽고, 앱 실행 또는 관련 검사를 완료합니다.

## 검증

기본적으로 다음 검사를 실행합니다.

```bash
flutter analyze
flutter test
```

UI 변경은 가능한 플랫폼에서 직접 실행하여 화면 깨짐과 주요 사용자 흐름을 확인합니다. API 변경은 서버가 배포되기 전까지 Fake Repository로 성공, 로딩, 실패 상태를 검증하고 제한 사항을 PR에 기록합니다.

## Merge 후 정리

```bash
git switch main
git pull --ff-only origin main
git branch -d feat/12-map-api
```

원격 브랜치 자동 삭제가 설정되지 않은 경우 GitHub에서 merge 후 브랜치를 함께 삭제합니다.
