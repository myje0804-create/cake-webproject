<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%--
  cake/list.jsp — 메인 케이크
  할 일: ③ 전체 상품 목록, 카테고리(레터링/캐릭터/도시락/플라워) 조회, 가격순·이름순·리뷰 많은 순 정렬
  담당: 역할 A (README.md 역할 분담 참고)
--%>
<% String ctx = request.getContextPath(); %>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>메인 케이크 | Mine Cake</title>
  <link rel="stylesheet" href="<%= ctx %>/css/common.css">
  <link rel="stylesheet" href="<%= ctx %>/css/header.css">
  <link rel="stylesheet" href="<%= ctx %>/css/footer.css">
</head>
<body>
  <jsp:include page="/common/header.jsp" />

  <main class="container" style="padding-block: 56px;">
    <h1 class="section-title">메인 케이크</h1>
    <p class="section-sub">준비 중인 화면이에요. (③ 전체 상품 목록, 카테고리(레터링/캐릭터/도시락/플라워) 조회, 가격순·이름순·리뷰 많은 순 정렬)</p>
  </main>

  <jsp:include page="/common/footer.jsp" />
</body>
</html>
