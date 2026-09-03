# Blick App

Blick은 학생의 귀가 버스 이용을 돕는 Flutter 애플리케이션입니다. 버스 신청 및 변경, QR 출석 확인, 미탑승 신청, 공지사항 확인과 경로 조회 기능을 제공합니다.

현재 UI 구현을 마치고 서버 API 연동을 준비하는 단계입니다. 서버가 아직 배포되지 않아 일부 화면은 하드코딩 데이터로 동작하며, OpenAPI 명세를 기준으로 모델과 Repository를 준비하고 있습니다.

## 주요 기능

- 이메일 로그인 및 JWT 인증
- 귀가 버스 신청 및 변경
- QR 스캔을 통한 출석 확인
- 미탑승 신청 및 취소
- 학생 공지사항 조회 및 읽음 처리
- 카카오맵 기반 현재 위치와 경로 표시

## 기술 스택

- Flutter / Dart
- Dio: HTTP API 통신
- flutter_dotenv: 로컬 환경변수 로드
- flutter_secure_storage: access/refresh token 보관 예정
- Riverpod: 인증 및 API 상태관리 도입 예정
- mobile_scanner: QR 코드 인식
- kakao_map_plugin: 카카오맵 표시

## 현재 개발 상태

| 영역 | 상태 |
| --- | --- |
| 화면 및 기본 내비게이션 | 구현됨 |
| 카카오맵 표시 | 구현됨 |
| QR 카메라 스캔 | 기본 동작 구현됨 |
| 공통 Dio 클라이언트 | 기본 설정 구현됨 |
| 로그인 | 하드코딩 상태, API 연동 예정 |
| 버스·출석·공지 API | 연동 예정 |
| 서버 통합 테스트 | 서버 배포 후 진행 |

진행할 작업과 API 계약 확인 사항은 [GitHub Issues](https://github.com/TeamBlick/app/issues)에서 관리합니다.

브랜치, 커밋, Pull Request 규칙은 [CONTRIBUTING.md](CONTRIBUTING.md)를 따릅니다.

## 시작하기

### 요구 환경

- Flutter SDK
- Dart SDK `>=3.8.1 <4.0.0`
- Android Studio 또는 Xcode

설치된 환경은 다음 명령으로 확인할 수 있습니다.

```bash
flutter doctor
```

### 설치 및 실행

```bash
git clone https://github.com/TeamBlick/app.git
cd app
flutter pub get
cp .env.example .env
flutter run
```

`.env`에 필요한 값을 입력합니다.

```dotenv
KAKAO_JAVASCRIPT_KEY=카카오_자바스크립트_키
API_BASE_URL=서버_API_주소
```

`.env`는 Git에 포함되지 않습니다. 실제 키나 토큰을 저장소에 커밋하지 마세요.

서버가 배포되기 전에는 실제 API 요청을 검증할 수 없습니다. 또한 Android 에뮬레이터나 실제 기기에서 `localhost`는 개발 서버 컴퓨터를 가리키지 않으므로, 통합 테스트 시 접근 가능한 서버 주소를 사용해야 합니다.

## 프로젝트 구조

현재 코드는 기능 단위 구조로 전환하는 과정에 있습니다.

```text
lib/
├── core/
│   ├── fun/                 # 이스터에그 기능
│   └── network/             # 공통 Dio 클라이언트
├── features/
│   ├── auth/                # 인증
│   ├── bus/                 # 버스 신청 및 변경
│   ├── home/                # 홈 화면
│   ├── profile/             # 프로필
│   └── qr/                  # QR 출석
├── screens/                 # features로 이동 예정인 기존 화면
├── shared/
│   └── widgets/             # 여러 기능에서 재사용하는 위젯
└── main.dart
```

API 연동이 진행되면 각 기능은 필요한 범위에서 다음 구조를 사용합니다.

```text
features/<feature>/
├── data/
│   ├── datasource/          # Dio API 호출
│   ├── models/              # Request/Response 모델
│   └── repositories/        # 실제/Fake Repository 구현
├── domain/                  # 공통 규칙이 생길 때만 추가
└── presentation/
    ├── providers/           # 공유 상태
    ├── screens/             # 화면
    └── widgets/             # 기능 전용 위젯
```

작은 기능에 불필요한 계층을 만들지 않고, 여러 화면에서 공유하거나 테스트 대역이 필요한 로직만 분리합니다.

## API 연동 원칙

- 모든 요청은 공통 Dio 클라이언트를 사용합니다.
- API 응답을 UI에서 `Map<String, dynamic>`으로 직접 다루지 않습니다.
- access/refresh token은 `flutter_secure_storage`에 저장합니다.
- 화면은 Repository를 통해 데이터를 요청합니다.
- 서버 미배포 기간에는 Swagger와 동일한 형태의 Fake Repository를 사용합니다.
- 비밀번호와 인증 토큰은 로그에 출력하지 않습니다.

## 검사

```bash
flutter analyze
flutter test
```

## 커밋 컨벤션

형식은 `Type: 작업 내용`이며 작업 내용은 한글로 작성합니다. 함수명, 클래스명, 변수명과 전문용어는 코드에서 사용하는 영어 표기를 유지합니다.

| Type | 사용 시점 |
| --- | --- |
| `Feat` | 기능 추가 |
| `Fix` | 동작하지 않는 기능 수정 |
| `Refactor` | 동작을 유지하면서 구조 개선 |
| `Hotfix` | 배포 상태의 긴급 수정 |
| `Docs` | README 등 실행에 영향을 주지 않는 문서 변경 |
| `Remove` | 파일, 폴더 또는 코드 삭제 |
| `Test` | 테스트 추가 및 수정 |
| `Chore` | 의존성, Gradle, YAML 등 개발 환경 변경 |
| `Style` | 포맷, 공백, 정렬, import 정리 |

예시:

```text
Feat: 로그인 API 연동
Fix: refresh token 저장 오류 수정
Refactor: AuthRepository로 로그인 로직 분리
Docs: 로컬 실행 방법 추가
```
