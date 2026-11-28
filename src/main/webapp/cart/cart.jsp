<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List, com.minecake.dto.CartItem, com.minecake.util.HtmlUtil" %>
<%--
  cart/cart.jsp — 장바구니 (⑥)
  담당: 역할 B · 데이터: CartServlet(GET /cart)이 cartItems, cartTotal을 넣어서 보내줌
  ※ 이 파일을 주소창에서 바로 열면 데이터가 없으므로 /cart 로 다시 보냄
--%>
<%
    String ctx = request.getContextPath();
    @SuppressWarnings("unchecked")
    List<CartItem> items = (List<CartItem>) request.getAttribute("cartItems");
    if (items == null) {
        response.sendRedirect(ctx + "/cart");
        return;
    }
    int total = (Integer) request.getAttribute("cartTotal");
    String msg = request.getParameter("msg");
%>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>장바구니 | Mine Cake</title>
  <link rel="stylesheet" href="<%= ctx %>/css/common.css">
  <link rel="stylesheet" href="<%= ctx %>/css/header.css">
  <link rel="stylesheet" href="<%= ctx %>/css/footer.css">
  <link rel="stylesheet" href="<%= ctx %>/css/cart.css">
</head>
<body>
  <jsp:include page="/common/header.jsp" />

  <main class="container cart-page">
    <h1 class="section-title">장바구니</h1>
    <p class="section-sub">담은 케이크의 문구와 옵션을 확인해 주세요</p>

    <% if ("added".equals(msg)) { %>
      <p class="cart-toast">장바구니에 담았어요.</p>
    <% } else if ("deleted".equals(msg)) { %>
      <p class="cart-toast">장바구니에서 뺐어요.</p>
    <% } else if ("empty".equals(msg)) { %>
      <p class="cart-toast cart-toast-error">장바구니가 비어 있어서 주문할 수 없어요.</p>
    <% } else if ("noProduct".equals(msg)) { %>
      <p class="cart-toast cart-toast-error">없는 상품이에요. 상품 목록에서 다시 골라 주세요.</p>
    <% } %>

    <% if (items.isEmpty()) { %>
      <!-- 빈 장바구니 -->
      <section class="cart-empty">
        <p class="cart-empty-title">장바구니가 비어 있어요</p>
        <p>마음에 드는 디자인을 골라 나만의 문구를 넣어 보세요.</p>
        <a href="<%= ctx %>/cake/list.jsp" class="btn btn-orange">케이크 보러 가기</a>
      </section>
    <% } else { %>

    <div class="cart-layout">
      <!-- 왼쪽: 담은 상품 목록 -->
      <ul class="cart-list">
        <% for (CartItem item : items) { %>
          <li class="cart-item">
            <div class="cart-thumb">
              <% if (item.getImageUrl() != null) { %>
                <img src="<%= ctx + item.getImageUrl() %>" alt="" onerror="this.remove()">
              <% } %>
            </div>

            <div class="cart-info">
              <a class="cart-name" href="<%= ctx %>/cake/detail.jsp?id=<%= item.getProductId() %>"><%= HtmlUtil.escape(item.getProductName()) %></a>
              <% if (item.getOptions() != null) { %>
                <p class="cart-options"><%= HtmlUtil.escape(item.getOptions()) %></p>
              <% } %>
              <% if (item.getLettering() != null) { %>
                <p class="cart-lettering"><span>레터링</span>"<%= HtmlUtil.escape(item.getLettering()) %>"</p>
              <% } %>
              <% if (item.getRequest() != null) { %>
                <p class="cart-request"><span>요청사항</span><%= HtmlUtil.escape(item.getRequest()) %></p>
              <% } %>
              <p class="cart-unit">1개 <%= HtmlUtil.won(item.getPrice()) %>원</p>
            </div>

            <div class="cart-actions">
              <!-- 수량 변경 -->
              <form method="post" action="<%= ctx %>/cart" class="qty-form">
                <input type="hidden" name="action" value="update">
                <input type="hidden" name="cartId" value="<%= item.getCartId() %>">
                <button type="button" class="qty-btn" data-step="-1" aria-label="수량 빼기">−</button>
                <input type="number" name="quantity" class="qty-input" id="qty-<%= item.getCartId() %>"
                       value="<%= item.getQuantity() %>" min="1" max="10" aria-label="수량">
                <button type="button" class="qty-btn" data-step="1" aria-label="수량 더하기">+</button>
                <noscript><button type="submit" class="btn">변경</button></noscript>
              </form>

              <p class="cart-line-total"><%= HtmlUtil.won(item.getLineTotal()) %>원</p>

              <!-- 삭제 -->
              <form method="post" action="<%= ctx %>/cart" class="delete-form">
                <input type="hidden" name="action" value="delete">
                <input type="hidden" name="cartId" value="<%= item.getCartId() %>">
                <button type="submit" class="delete-btn">삭제</button>
              </form>
            </div>
          </li>
        <% } %>
      </ul>

      <!-- 오른쪽: 결제 금액 -->
      <aside class="cart-summary">
        <h2>결제 예정 금액</h2>
        <div class="summary-row"><span>상품 <%= items.size() %>건</span><span><%= HtmlUtil.won(total) %>원</span></div>
        <div class="summary-row"><span>픽업</span><span>매장 방문 (무료)</span></div>
        <div class="summary-total"><span>합계</span><strong><%= HtmlUtil.won(total) %>원</strong></div>
        <a href="<%= ctx %>/order?action=checkout" class="btn btn-orange btn-block">주문하기</a>
        <a href="<%= ctx %>/cake/list.jsp" class="btn btn-block">케이크 더 담기</a>
        <p class="summary-note">픽업 날짜와 시간은 다음 단계에서 골라요.</p>
      </aside>
    </div>
    <% } %>
  </main>

  <jsp:include page="/common/footer.jsp" />
  <script src="<%= ctx %>/js/cart.js"></script>
</body>
</html>
