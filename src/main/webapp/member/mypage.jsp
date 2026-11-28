<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List, java.time.format.DateTimeFormatter, java.util.Locale, com.minecake.dto.Member, com.minecake.dto.Order, com.minecake.dto.OrderItem, com.minecake.util.HtmlUtil" %>
<%--
  member/mypage.jsp — 마이페이지 (⑤ 주문 내역 및 제작 상태 조회)
  담당: 역할 B (예지) · 데이터: OrderServlet(GET /order?action=mypage)이 넣어 줌
  ※ 헤더의 사람 아이콘은 이 파일로 바로 오므로, 데이터가 없으면 /order?action=mypage 로 다시 보냄
--%>
<%
    String ctx = request.getContextPath();
    @SuppressWarnings("unchecked")
    List<Order> orders = (List<Order>) request.getAttribute("orders");
    if (orders == null) {
        response.sendRedirect(ctx + "/order?action=mypage");
        return;
    }
    Member me = (Member) request.getAttribute("member");
    String msg = (String) request.getAttribute("msg");
    DateTimeFormatter dayFmt = DateTimeFormatter.ofPattern("M월 d일 (E)", Locale.KOREAN);
    DateTimeFormatter timeFmt = DateTimeFormatter.ofPattern("HH:mm");
    DateTimeFormatter orderedFmt = DateTimeFormatter.ofPattern("yyyy.MM.dd HH:mm");
    String[] stepNames = { "주문 접수", "제작 중", "픽업 대기", "픽업 완료" };
%>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>마이페이지 | Mine Cake</title>
  <link rel="stylesheet" href="<%= ctx %>/css/common.css">
  <link rel="stylesheet" href="<%= ctx %>/css/header.css">
  <link rel="stylesheet" href="<%= ctx %>/css/footer.css">
  <link rel="stylesheet" href="<%= ctx %>/css/order.css">
</head>
<body>
  <jsp:include page="/common/header.jsp" />

  <main class="container order-page">
    <h1 class="section-title">마이페이지</h1>
    <p class="section-sub">주문한 케이크가 지금 어디까지 만들어졌는지 확인해 보세요</p>

    <% if ("already".equals(msg)) { %>
      <p class="order-alert info">이미 처리된 주문이에요. 아래 주문 내역을 확인해 주세요.</p>
    <% } %>

    <div class="mypage-layout">
      <!-- 왼쪽: 내 정보 -->
      <aside class="profile-card">
        <p class="profile-name"><%= HtmlUtil.escape(me.getName()) %>님</p>
        <p class="profile-id">@<%= HtmlUtil.escape(me.getLoginId()) %></p>
        <dl class="buyer-list">
          <dt>연락처</dt><dd><%= me.getPhone() == null ? "-" : HtmlUtil.escape(me.getPhone()) %></dd>
          <dt>이메일</dt><dd><%= me.getEmail() == null ? "-" : HtmlUtil.escape(me.getEmail()) %></dd>
          <dt>주문</dt><dd><%= orders.size() %>건</dd>
        </dl>
        <a href="<%= ctx %>/member/edit.jsp" class="btn btn-block">내 정보 수정</a>
      </aside>

      <!-- 오른쪽: 주문 내역 -->
      <section>
        <% if (orders.isEmpty()) { %>
          <div class="empty-orders">
            <p>아직 주문한 케이크가 없어요.</p>
            <a href="<%= ctx %>/cake" class="btn btn-orange">케이크 보러 가기</a>
          </div>
        <% } else { %>
          <ul class="order-list">
            <% for (Order o : orders) { int step = o.getStatusStep(); %>
              <li class="order-card">
                <div class="order-card-head">
                  <p class="order-no">주문 #<%= o.getOrderId() %>
                    <% if (o.getOrderedAt() != null) { %><small><%= o.getOrderedAt().format(orderedFmt) %> 주문</small><% } %>
                  </p>
                  <span class="status-badge <%= step == 3 ? "done" : "" %>"><%= o.getStatusLabel() %></span>
                </div>

                <!-- 제작 상태 4단계: 관리자가 상태를 바꾸면 여기 막대가 채워짐 -->
                <ol class="status-steps" aria-label="제작 상태">
                  <% for (int i = 0; i < stepNames.length; i++) { %>
                    <li class="<%= i <= step ? "on" : "" %>" <%= i == step ? "aria-current=\"step\"" : "" %>><%= stepNames[i] %></li>
                  <% } %>
                </ol>

                <ul class="order-items">
                  <% for (OrderItem item : o.getItems()) { %>
                    <li class="order-item">
                      <div class="order-thumb">
                        <% if (item.getImageUrl() != null) { %><img src="<%= ctx + item.getImageUrl() %>" alt="" onerror="this.remove()"><% } %>
                      </div>
                      <div>
                        <p class="order-item-name"><%= HtmlUtil.escape(item.getProductName()) %> × <%= item.getQuantity() %></p>
                        <% if (item.getOptions() != null) { %><p class="order-item-sub"><%= HtmlUtil.escape(item.getOptions()) %></p><% } %>
                        <% if (item.getLettering() != null) { %><p class="order-item-lettering">"<%= HtmlUtil.escape(item.getLettering()) %>"</p><% } %>
                      </div>
                      <p class="order-item-price"><%= HtmlUtil.won(item.getLineTotal()) %>원</p>
                    </li>
                  <% } %>
                </ul>

                <div class="order-card-foot">
                  <span>픽업 <span class="pickup-when"><%= o.getPickupDate() == null ? "-" : o.getPickupDate().format(dayFmt) %> <%= o.getPickupTime() == null ? "" : o.getPickupTime().format(timeFmt) %></span></span>
                  <span>결제 금액 <strong><%= HtmlUtil.won(o.getTotalPrice()) %>원</strong></span>
                </div>
              </li>
            <% } %>
          </ul>
        <% } %>
      </section>
    </div>
  </main>

  <jsp:include page="/common/footer.jsp" />
</body>
</html>
