<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%--
  admin/memberList.jsp — 회원 관리
  할 일: 전체 회원 목록, 회원별 주문 이력
  담당: 역할 C (README.md 역할 분담 참고)
--%>
<% String ctx = request.getContextPath(); %>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>회원 관리 | Mine Cake</title>
  <link rel="stylesheet" href="<%= ctx %>/css/common.css">
  <link rel="stylesheet" href="<%= ctx %>/css/header.css">
  <link rel="stylesheet" href="<%= ctx %>/css/footer.css">
</head>
<body>
  <jsp:include page="/common/header.jsp" />

  <main class="container" style="padding-block: 56px;">
    <h1 class="section-title">회원 관리</h1>
    <p class="section-sub">준비 중인 화면이에요. (전체 회원 목록, 회원별 주문 이력)</p>
  </main>

  <jsp:include page="/common/footer.jsp" />
</body>
</html>
