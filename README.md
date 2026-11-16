# 🎂 Mine Cake

AI 기반 맞춤 추천 커스텀 케이크 주문 사이트
웹프로그래밍응용 텀프로젝트 · 최종 발표 **12/21(월) Zoom**

| 팀장 | 팀원 | 팀원 |
|---|---|---|
| 문예지 | 전소은 | 정선우 |

---

## 🛠 개발 환경

- Java 17 이상, Maven
- Tomcat 10 이상 (jakarta 패키지 사용)
- MySQL 8
- VS Code 확장 (폴더를 열면 설치 추천이 뜸)
  - Extension Pack for Java
  - Community Server Connectors (Tomcat 실행)

## 🚀 처음 실행하는 법

1. `git clone` 후 VS Code에서 `cake-webproject` 폴더 열기
2. MySQL Workbench에서 `sql/schema.sql` → `sql/sample_data.sql` 순서로 실행
3. `src/main/java/com/minecake/util/DBUtil.java`의 비밀번호를 내 MySQL 비밀번호로 수정
   (⚠ 이 수정은 커밋하지 않기)
4. 터미널에서 `mvn package` → `target/cake-webproject.war` 생성
5. VS Code 왼쪽 **SERVERS** 탭 → Tomcat 추가 → war 배포 → 서버 시작
6. 브라우저에서 `http://localhost:8080/cake-webproject/` 접속

시연 계정: 관리자 `admin / admin1234`, 일반 `yeji / 1234`

---

## 📁 폴더 구조

```
cake-webproject/
├─ pom.xml                       Maven 설정
├─ sql/
│  ├─ schema.sql                 테이블 생성
│  └─ sample_data.sql            시연용 데이터
└─ src/main/
   ├─ java/com/minecake/
   │  ├─ controller/             요청 받는 Servlet
   │  │  └─ admin/               관리자 Servlet
   │  ├─ dao/                    DB 조회·저장
   │  ├─ dto/                    데이터 묶음 (Member, Product, Order …)
   │  ├─ ai/GemmaClient.java     Gemma 3 호출
   │  └─ util/DBUtil.java        DB 연결
   └─ webapp/
      ├─ index.jsp               메인 (배너 · Best Design · 주문 방법 · 후기)
      ├─ common/                 header.jsp · footer.jsp (모든 페이지 공통)
      ├─ ai/                     ① AI 케이크
      ├─ support/                ② 고객센터 (공지 · FAQ · 1:1 문의)
      ├─ cake/                   ③ 메인 케이크 (목록 · 상세) + ⑦ 커스텀 주문
      ├─ addon/                  ④ 추가 상품
      ├─ member/                 ⑤ 회원 (로그인 · 가입 · 마이페이지 · 수정)
      ├─ cart/                   ⑥ 장바구니 · 결제 · 주문 완료
      ├─ review/                 ⑧ 고객 후기
      ├─ policy/                 이용약관 · 개인정보 처리방침
      ├─ admin/                  관리자 화면
      ├─ css/  js/  images/
      └─ WEB-INF/web.xml
```

## 🎨 디자인 규칙

- 색·폰트는 **`css/common.css`의 변수만** 사용 (예: `var(--orange)`, `var(--font-hand)`)
- 새 페이지는 `cake/list.jsp`처럼 맨 위에 `header.jsp`, 맨 아래 `footer.jsp`를 include
- 각자 화면 전용 스타일은 `css/` 아래 담당 파일에 작성

---

## 👥 역할 분담 (이름은 회의 후 기입)

| 역할 | 담당 | 맡는 화면·파일 |
|---|---|---|
| **A** 상품 · 커스텀 | | ③ 메인 케이크, ④ 추가 상품, ⑦ 커스텀 주문, 메인 화면 / `CakeServlet`, `MainServlet`, `ProductDAO` |
| **B** 회원 · 주문 | | ⑤ 회원, ⑥ 장바구니·결제, ⑧ 후기 / `MemberServlet`, `CartServlet`, `OrderServlet`, `ReviewServlet` |
| **C** 관리자 · AI | | ① AI 케이크, ② 고객센터, 관리자 화면 / `AiServlet`, `GemmaClient`, `admin/*` |

각 파일 맨 위 주석에 담당 역할(A/B/C)이 적혀 있어요.

## 🌿 Git 규칙

- `main`은 항상 실행되는 상태로 유지 → **main에 직접 push 금지**
- 작업할 때는 브랜치 만들기: `feature/기능이름` (예: `feature/cart`, `feature/admin-order`)
- 작업 끝나면 Pull Request → 팀원 1명 확인 후 merge
- 작업 시작 전에 항상 `git pull origin main`
- 커밋 메시지: `[기능] 내용` (예: `[cart] 장바구니 수량 변경 추가`)
- API 키, DB 비밀번호는 절대 커밋하지 않기

## 📅 중간 목표

- **11/29** 셋이 함께 테스트 주문 1건 넣기 (레터링 문구가 관리자 화면까지 전달되는지 확인)
- **12/6** 주요 기능 개발 종료
- **12/21** 최종 발표
