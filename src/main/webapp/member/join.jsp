<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.minecake.util.HtmlUtil" %>
<%--
  member/join.jsp — 회원가입 (⑤ 회원)
  담당: 역할 B · 처리: MemberServlet (POST /member, action=join)
--%>
<%
    String ctx = request.getContextPath();
    String error = (String) request.getAttribute("error");   // 가입 실패 메시지
%>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>회원가입 | Mine Cake</title>
  <link rel="stylesheet" href="<%= ctx %>/css/common.css">
  <link rel="stylesheet" href="<%= ctx %>/css/header.css">
  <link rel="stylesheet" href="<%= ctx %>/css/footer.css">
  <link rel="stylesheet" href="<%= ctx %>/css/member.css">
</head>
<body>
  <jsp:include page="/common/header.jsp" />

  <main class="container member-page">
    <section class="member-card">
      <h1 class="member-title">회원가입</h1>
      <p class="member-sub">픽업 안내를 위해 이름과 연락처를 정확히 적어 주세요</p>

      <% if (error != null) { %>
        <p class="alert alert-error"><%= HtmlUtil.escape(error) %></p>
      <% } %>

      <form method="post" action="<%= ctx %>/member" class="member-form" id="joinForm">
        <input type="hidden" name="action" value="join">

        <label for="loginId">아이디 <span class="req">*</span></label>
        <input type="text" id="loginId" name="loginId" value="<%= HtmlUtil.escape(request.getParameter("loginId")) %>"
               required pattern="[a-zA-Z0-9]{4,20}" autocomplete="username"
               title="영문과 숫자 4~20자">
        <p class="hint">영문과 숫자 4~20자</p>

        <label for="password">비밀번호 <span class="req">*</span></label>
        <input type="password" id="password" name="password" required minlength="6" autocomplete="new-password">
        <p class="hint">6자 이상</p>

        <label for="passwordConfirm">비밀번호 확인 <span class="req">*</span></label>
        <input type="password" id="passwordConfirm" name="passwordConfirm" required minlength="6" autocomplete="new-password">
        <p class="hint" id="pwMatch"></p>

        <label for="name">이름 <span class="req">*</span></label>
        <input type="text" id="name" name="name" value="<%= HtmlUtil.escape(request.getParameter("name")) %>"
               required maxlength="30" autocomplete="name">

        <label for="phone">전화번호</label>
        <input type="tel" id="phone" name="phone" value="<%= HtmlUtil.escape(request.getParameter("phone")) %>"
               placeholder="010-1234-5678" pattern="[0-9\-]{9,13}" autocomplete="tel">

        <label for="email">이메일</label>
        <input type="email" id="email" name="email" value="<%= HtmlUtil.escape(request.getParameter("email")) %>"
               maxlength="100" autocomplete="email">

        <button type="submit" class="btn btn-orange btn-block">가입하기</button>
      </form>

      <p class="member-switch">이미 회원이신가요? <a href="<%= ctx %>/member/login.jsp">로그인</a></p>
    </section>
  </main>

  <jsp:include page="/common/footer.jsp" />

  <script>
    // 비밀번호 확인이 맞는지 입력하는 동안 바로 알려주기
    (function () {
      const pw = document.getElementById('password');
      const pw2 = document.getElementById('passwordConfirm');
      const msg = document.getElementById('pwMatch');
      function check() {
        if (!pw2.value) { msg.textContent = ''; return; }
        const ok = pw.value === pw2.value;
        msg.textContent = ok ? '비밀번호가 일치해요.' : '비밀번호가 일치하지 않아요.';
        msg.className = 'hint ' + (ok ? 'ok' : 'bad');
      }
      pw.addEventListener('input', check);
      pw2.addEventListener('input', check);
    })();
  </script>
</body>
</html>
