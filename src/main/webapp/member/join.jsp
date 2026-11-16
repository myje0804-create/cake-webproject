<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%--
  member/join.jsp — 회원가입
  할 일: ⑤ 회원가입
  담당: 역할 B (README.md 역할 분담 참고)
--%>
<% String ctx = request.getContextPath(); %>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>회원가입 | Mine Cake</title>
  <link rel="stylesheet" href="<%= ctx %>/css/common.css">
  <link rel="stylesheet" href="<%= ctx %>/css/header.css">
  <link rel="stylesheet" href="<%= ctx %>/css/footer.css">
</head>
<body>
  <jsp:include page="/common/header.jsp" />

  <main class="container" style="padding-block: 56px;">
    <h1 class="section-title">회원가입</h1>
    <p class="section-sub">준비 중인 화면이에요. (⑤ 회원가입)</p>
  </main>

  <jsp:include page="/common/footer.jsp" />
</body>
</html>
