<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.minecake.util.HtmlUtil" %>
<%--
  member/login.jsp — 로그인 (⑤ 회원)
  담당: 역할 B · 처리: MemberServlet (POST /member, action=login)
--%>
<%
    String ctx = request.getContextPath();
    String error = (String) request.getAttribute("error");        // 로그인 실패 메시지
    boolean joined = "1".equals(request.getParameter("joined"));  // 회원가입 직후
    boolean need = "1".equals(request.getParameter("need"));      // 로그인이 필요한 화면에서 넘어옴
    String returnUrl = request.getParameter("returnUrl");          // 로그인 후 돌아갈 곳
    String loginId = request.getParameter("loginId");              // 실패 시 아이디 다시 채우기
%>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>로그인 | Mine Cake</title>
  <link rel="stylesheet" href="<%= ctx %>/css/common.css">
  <link rel="stylesheet" href="<%= ctx %>/css/header.css">
  <link rel="stylesheet" href="<%= ctx %>/css/footer.css">
  <link rel="stylesheet" href="<%= ctx %>/css/member.css">
</head>
<body>
  <jsp:include page="/common/header.jsp" />

  <main class="container member-page">
    <section class="member-card">
      <h1 class="member-title">로그인</h1>
      <p class="member-sub">로그인하고 나만의 케이크를 주문해 보세요</p>

      <% if (joined) { %>
        <p class="alert alert-ok">회원가입이 완료됐어요. 로그인해 주세요.</p>
      <% } else if (need) { %>
        <p class="alert alert-info">로그인이 필요한 메뉴예요.</p>
      <% } %>
      <% if (error != null) { %>
        <p class="alert alert-error"><%= HtmlUtil.escape(error) %></p>
      <% } %>

      <form method="post" action="<%= ctx %>/member" class="member-form">
        <input type="hidden" name="action" value="login">
        <input type="hidden" name="returnUrl" value="<%= HtmlUtil.escape(returnUrl) %>">

        <label for="loginId">아이디</label>
        <input type="text" id="loginId" name="loginId" value="<%= HtmlUtil.escape(loginId) %>"
               required autocomplete="username" autofocus>

        <label for="password">비밀번호</label>
        <input type="password" id="password" name="password" required autocomplete="current-password">

        <button type="submit" class="btn btn-orange btn-block">로그인</button>
      </form>

      <p class="member-switch">아직 회원이 아니신가요? <a href="<%= ctx %>/member/join.jsp">회원가입</a></p>
    </section>
  </main>

  <jsp:include page="/common/footer.jsp" />
</body>
</html>
