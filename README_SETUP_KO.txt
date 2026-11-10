hearthisong — 친구들과 함께 쓰는 음악 큐레이션 웹앱
====================================================

현재 들어 있는 파일
- index.html : 화면 구조
- style.css : 블랙 & 아이보리 디자인
- app.js : 회원가입/로그인, 플레이리스트, YouTube 링크, 좋아요, 공유
- schema.sql : Supabase 데이터베이스 테이블 및 접근 권한(RLS)

중요: 이 프로젝트는 실제 공용 데이터베이스와 공개 주소에 연결할 준비가 된 MVP 소스입니다.
아직 Supabase 프로젝트와 Vercel 배포가 연결되지 않았으므로, 이 파일만 열면 친구들과 데이터가 공유되지는 않습니다.

[1] Supabase 프로젝트 만들기
1. https://supabase.com 에서 계정을 만들고 새 프로젝트를 생성합니다.
2. 프로젝트 대시보드의 SQL Editor를 엽니다.
3. 이 폴더의 schema.sql 전체 내용을 붙여넣고 Run을 누릅니다.
4. Project Settings > API 에서 Project URL과 anon/public key를 확인합니다.
   절대 service_role 키를 브라우저 코드에 넣지 마세요.

[2] 앱에 Supabase 연결하기
1. app.js 맨 위의 아래 두 값을 본인의 프로젝트 값으로 바꿉니다.
   const SUPABASE_URL = 'YOUR_SUPABASE_URL';
   const SUPABASE_ANON_KEY = 'YOUR_SUPABASE_ANON_KEY';
2. anon/public 키만 사용하세요. DB 접근은 schema.sql의 RLS 정책이 제어합니다.

[3] Vercel에 공개하기
1. https://vercel.com 에 로그인합니다.
2. 이 폴더를 GitHub 저장소에 올린 뒤 Vercel에서 해당 저장소를 Import 합니다.
3. Framework Preset은 Other, Build Command는 비워두고 Output Directory는 ./ 로 설정합니다.
4. Deploy를 누르면 공개 주소가 만들어집니다.
5. 친구들에게 그 주소를 보내면 각자 가입해 사용할 수 있습니다.

[4] 이메일 로그인 설정
Supabase Authentication > URL Configuration에서 배포된 사이트 주소를 Site URL과 Redirect URLs에 추가합니다.
처음에는 이메일 확인(Confirm email)이 켜져 있을 수 있습니다. 이 경우 가입 확인 메일을 눌러야 로그인됩니다.

[기능]
- 이메일 회원가입/로그인
- 닉네임 표시
- 공개 플레이리스트 검색 및 탐색
- 내 플레이리스트 생성
- YouTube 영상 링크로 노래 추가 및 임베드 재생
- 플레이리스트 좋아요
- 공유 링크 복사
- 공개/비공개 접근 정책

[현재 MVP 제한]
- YouTube 영상은 영상 소유자/지역/연령 설정 등에 따라 임베드가 막힐 수 있습니다.
- YouTube 음악은 백그라운드 재생이나 자체 플레이어의 곡 넘김 제어가 보장되지 않습니다.
- 현재 로그인은 이메일/비밀번호 방식입니다.
- 프로필 사진, 팔로우, 댓글, 실시간 공동 편집은 아직 없습니다.
- 실제 서비스 공개 전에는 스팸 방지, 이메일 인증, 신고/차단, 개인정보 안내를 추가하는 것이 좋습니다.
