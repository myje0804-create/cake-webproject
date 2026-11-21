<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.minecake.dto.Member, com.minecake.util.HtmlUtil" %>
<%--
  header.jsp — 모든 페이지 맨 위에 붙는 공통 메뉴
  사용법: <jsp:include page="/common/header.jsp" />
  스케치 번호: ① AI 케이크 ② 고객센터 ③ 메인 케이크 ④ 추가 상품 ⑤ 회원 ⑥ 장바구니
--%>
<%
    String ctx = request.getContextPath();

    // 로그인 정보: 로그인 성공 시 MemberServlet이 세션에 "loginUser"(Member)를 넣어 둠
    Member loginUser = (Member) session.getAttribute("loginUser");
    boolean isLogin = (loginUser != null);
    boolean isAdmin = isLogin && "ADMIN".equals(loginUser.getRole());

    // 장바구니 개수: 로그인·담기·삭제할 때 MemberServlet/CartServlet이 "cartCount"를 갱신
    Integer cartCount = (Integer) session.getAttribute("cartCount");
    if (cartCount == null) cartCount = 0;
%>
<header class="site-header">
  <div class="container header-inner">

    <!-- 로고 -->
    <a href="<%= ctx %>/index.jsp" class="logo">
      Mine Cake
      <svg class="logo-icon" viewBox="0 0 32 32" aria-hidden="true">
        <path d="M5 27h22M7 27V17h18v10M7 21c3 2 5 2 7 0s5-2 7 0 4 2 4 0M11 17v-4M16 17v-4M21 17v-4"
              fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round"/>
        <path d="M11 10c-1-1 0-3 0-3s1 2 0 3zM16 10c-1-1 0-3 0-3s1 2 0 3zM21 10c-1-1 0-3 0-3s1 2 0 3z"
              fill="currentColor"/>
      </svg>
    </a>

    <!-- 메뉴 ①~④ -->
    <nav class="main-nav" aria-label="주요 메뉴">
      <a href="<%= ctx %>/ai/aiCake.jsp">AI 케이크</a>       <!-- ① -->
      <a href="<%= ctx %>/support/notice.jsp">고객센터</a>    <!-- ② -->
      <a href="<%= ctx %>/cake/list.jsp">메인 케이크</a>      <!-- ③ -->
      <a href="<%= ctx %>/addon/list.jsp">추가 상품</a>       <!-- ④ -->
    </nav>

    <!-- ⑤ 회원 / ⑥ 장바구니 -->
    <div class="header-icons">
      <a href="<%= ctx %><%= isLogin ? "/member/mypage.jsp" : "/member/login.jsp" %>"
         class="icon-btn" title="<%= isLogin ? "마이페이지" : "로그인" %>">
        <svg viewBox="0 0 24 24" aria-hidden="true">
          <circle cx="12" cy="8" r="4" fill="none" stroke="currentColor" stroke-width="1.6"/>
          <path d="M4 21c1-4.5 4-6.5 8-6.5s7 2 8 6.5" fill="none" stroke="currentColor" stroke-width="1.6" stroke-linecap="round"/>
        </svg>
        <span class="sr-only"><%= isLogin ? "마이페이지" : "로그인" %></span>
      </a>

      <a href="<%= ctx %>/cart" class="icon-btn" title="장바구니">
        <svg viewBox="0 0 24 24" aria-hidden="true">
          <path d="M5 8h14l-1 13H6L5 8z" fill="none" stroke="currentColor" stroke-width="1.6" stroke-linejoin="round"/>
          <path d="M9 8V6a3 3 0 0 1 6 0v2" fill="none" stroke="currentColor" stroke-width="1.6"/>
        </svg>
        <% if (cartCount > 0) { %>
          <span class="cart-badge"><%= cartCount %></span>
        <% } %>
        <span class="sr-only">장바구니</span>
      </a>

      <% if (isLogin) { %>
        <span class="hello"><%= HtmlUtil.escape(loginUser.getName()) %>님</span>
        <% if (isAdmin) { %>
          <a href="<%= ctx %>/admin/dashboard.jsp" class="logout-link">관리자</a>
        <% } %>
        <a href="<%= ctx %>/member?action=logout" class="logout-link">로그아웃</a>
      <% } %>
    </div>
  </div>
</header>
