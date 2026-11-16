<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%--
  addon/list.jsp — 추가 상품
  할 일: ④ 숫자초, 토퍼, 케이크 칼 등
  담당: 역할 A (README.md 역할 분담 참고)
--%>
<% String ctx = request.getContextPath(); %>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>추가 상품 | Mine Cake</title>
  <link rel="stylesheet" href="<%= ctx %>/css/common.css">
  <link rel="stylesheet" href="<%= ctx %>/css/header.css">
  <link rel="stylesheet" href="<%= ctx %>/css/footer.css">
</head>
<body>
  <jsp:include page="/common/header.jsp" />

  <main class="container" style="padding-block: 56px;">
    <h1 class="section-title">추가 상품</h1>
    <p class="section-sub">준비 중인 화면이에요. (④ 숫자초, 토퍼, 케이크 칼 등)</p>
  </main>

  <jsp:include page="/common/footer.jsp" />
</body>
</html>
