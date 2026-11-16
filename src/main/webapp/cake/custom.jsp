<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%--
  cake/custom.jsp — 커스텀 주문
  할 일: ⑦ 디자인·색상·레터링 옵션 선택 + 미리보기 + 픽업 날짜·시간
  담당: 역할 A (README.md 역할 분담 참고)
--%>
<% String ctx = request.getContextPath(); %>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>커스텀 주문 | Mine Cake</title>
  <link rel="stylesheet" href="<%= ctx %>/css/common.css">
  <link rel="stylesheet" href="<%= ctx %>/css/header.css">
  <link rel="stylesheet" href="<%= ctx %>/css/footer.css">
</head>
<body>
  <jsp:include page="/common/header.jsp" />

  <main class="container" style="padding-block: 56px;">
    <h1 class="section-title">커스텀 주문</h1>
    <p class="section-sub">준비 중인 화면이에요. (⑦ 디자인·색상·레터링 옵션 선택 + 미리보기 + 픽업 날짜·시간)</p>
  </main>

  <jsp:include page="/common/footer.jsp" />
</body>
</html>
