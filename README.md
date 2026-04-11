## Commit Message Convention

형식:  
`<Type> : <Summary>`

- Type과 콜론 앞뒤 공백은 고정합니다. (`Feat :`, `Fix :` 처럼)
- Summary는 한 줄, 명확하게, 동사로 시작하는 것을 권장합니다.
- 예) `Feat : 로그인 화면 UI 추가`

### Types

- **Feat** : 새로운 기능 추가
- **Fix** : 버그 수정
- **Docs** : 문서 작업(README, 주석 외 문서 등)
- **Style** : 코드 포맷 변경(세미콜론 누락, 공백/정렬 등) *로직 변경 없음*
- **Refactor** : 프로덕션 코드 리팩토링(기능 동일, 구조 개선)
- **Test** : 테스트 코드 추가/수정
- **Chore** : 빌드/설정/패키지 매니저/의존성 업데이트 등 *(프로덕션 코드 변경 없음)*
- **Create** : 새로운 파일/폴더 추가
- **Comment** : 주석 추가/변경
- **Design** : CSS 등 UI 디자인 변경
- **Rename** : 파일/폴더명 변경 또는 이동만 수행
- **Remove** : 파일 삭제만 수행

### Examples

- `Feat : 회원가입 API 연동`
- `Fix : 로그인 토큰 저장 오류 수정`
- `Docs : 커밋 컨벤션 문서화`
- `Style : prettier 포맷 적용`
- `Refactor : auth 로직 분리`
- `Test : 로그인 유닛 테스트 추가`
- `Chore : 의존성 업데이트`
- `Create : assets 폴더 추가`
- `Comment : 로그인 로직 주석 보강`
- `Design : 버튼 hover 스타일 수정`
- `Rename : LoginPage -> SignInPage로 변경`
- `Remove : 사용하지 않는 이미지 삭제`
