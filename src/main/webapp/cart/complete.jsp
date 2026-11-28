<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.time.format.DateTimeFormatter, java.util.Locale, com.minecake.dto.Order, com.minecake.dto.OrderItem, com.minecake.util.HtmlUtil" %>
<%--
  cart/complete.jsp — 주문 완료 (⑥ 주문번호, 픽업 일시 안내)
  담당: 역할 B (예지) · 데이터: OrderServlet(GET /order?action=complete&id=)이 넣어 줌
--%>
<%
    String ctx = request.getContextPath();
    Order order = (Order) request.getAttribute("order");
    if (order == null) {
        response.sendRedirect(ctx + "/order?action=mypage");
        return;
    }
    String payLabel = (String) request.getAttribute("payLabel");
    DateTimeFormatter dayFmt = DateTimeFormatter.ofPattern("yyyy년 M월 d일 (E)", Locale.KOREAN);
    DateTimeFormatter timeFmt = DateTimeFormatter.ofPattern("HH:mm");
%>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>주문 완료 | Mine Cake</title>
  <link rel="stylesheet" href="<%= ctx %>/css/common.css">
  <link rel="stylesheet" href="<%= ctx %>/css/header.css">
  <link rel="stylesheet" href="<%= ctx %>/css/footer.css">
  <link rel="stylesheet" href="<%= ctx %>/css/order.css">
</head>
<body>
  <jsp:include page="/common/header.jsp" />

  <main class="container order-page">
    <section class="complete-card">
      <div class="complete-check" aria-hidden="true">✓</div>
      <h1 class="complete-title">주문이 접수됐어요!</h1>
      <p class="complete-sub">정성껏 만들어 둘게요. 픽업 날짜에 매장으로 와 주세요.</p>

      <dl class="complete-info">
        <dt>주문번호</dt><dd class="big">#<%= order.getOrderId() %></dd>
        <dt>픽업 일시</dt><dd><%= order.getPickupDate().format(dayFmt) %> <%= order.getPickupTime().format(timeFmt) %></dd>
        <dt>결제 금액</dt><dd><%= HtmlUtil.won(order.getTotalPrice()) %>원</dd>
        <dt>결제 수단</dt><dd><%= payLabel == null ? "모의 결제" : HtmlUtil.escape(payLabel) %> <small>(모의 결제)</small></dd>
        <dt>제작 상태</dt><dd><%= order.getStatusLabel() %></dd>
      </dl>

      <ul class="order-items">
        <% for (OrderItem item : order.getItems()) { %>
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

      <div class="complete-actions">
        <a href="<%= ctx %>/order?action=mypage" class="btn btn-orange">주문 내역 보기</a>
        <a href="<%= ctx %>/index.jsp" class="btn">메인으로</a>
      </div>
    </section>
  </main>

  <jsp:include page="/common/footer.jsp" />
</body>
</html>
