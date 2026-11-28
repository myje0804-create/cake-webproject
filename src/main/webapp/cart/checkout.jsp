<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List, java.util.Map, com.minecake.dto.CartItem, com.minecake.dto.Member, com.minecake.util.HtmlUtil" %>
<%--
  cart/checkout.jsp — 주문서 (⑥ 픽업 일시 선택 + 모의 결제)
  담당: 역할 B (예지) · 데이터: OrderServlet(GET /order?action=checkout)이 넣어 줌
  ※ 이 파일을 주소창에서 바로 열면 데이터가 없으므로 /order?action=checkout 으로 다시 보냄
--%>
<%
    String ctx = request.getContextPath();
    @SuppressWarnings("unchecked")
    List<CartItem> items = (List<CartItem>) request.getAttribute("cartItems");
    if (items == null) {
        response.sendRedirect(ctx + "/order?action=checkout");
        return;
    }
    int total = (Integer) request.getAttribute("cartTotal");
    @SuppressWarnings("unchecked")
    List<String> times = (List<String>) request.getAttribute("pickupTimes");
    @SuppressWarnings("unchecked")
    Map<String, String> pays = (Map<String, String>) request.getAttribute("payMethods");
    Member buyer = (Member) request.getAttribute("buyer");
    String minDate = (String) request.getAttribute("minDate");
    String maxDate = (String) request.getAttribute("maxDate");
    String error = (String) request.getAttribute("error");
    String errorText = null;
    if ("date".equals(error))  errorText = "픽업 날짜는 내일부터 30일 안에서 골라 주세요.";
    if ("time".equals(error))  errorText = "픽업 시간을 골라 주세요. (11:00 ~ 19:00)";
    if ("pay".equals(error))   errorText = "결제 수단을 골라 주세요.";
    if ("agree".equals(error)) errorText = "주문 내용 확인에 동의해 주세요.";
%>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>주문·결제 | Mine Cake</title>
  <link rel="stylesheet" href="<%= ctx %>/css/common.css">
  <link rel="stylesheet" href="<%= ctx %>/css/header.css">
  <link rel="stylesheet" href="<%= ctx %>/css/footer.css">
  <link rel="stylesheet" href="<%= ctx %>/css/order.css">
</head>
<body>
  <jsp:include page="/common/header.jsp" />

  <main class="container order-page">
    <h1 class="section-title">주문·결제</h1>
    <p class="section-sub">케이크를 찾으러 올 날짜와 시간을 골라 주세요</p>

    <% if (errorText != null) { %>
      <p class="order-alert"><%= errorText %></p>
    <% } %>

    <form method="post" action="<%= ctx %>/order" id="checkoutForm" class="checkout-layout">
      <input type="hidden" name="action" value="place">
      <input type="hidden" name="orderToken" value="<%= HtmlUtil.escape((String) request.getAttribute("orderToken")) %>">

      <div class="checkout-main">
        <!-- 1. 픽업 일시 -->
        <section class="order-box">
          <h2 class="order-box-title"><span class="step-badge">1</span>픽업 날짜·시간</h2>
          <p class="order-box-hint">매장에서 직접 받아 가요. 케이크 제작 때문에 <strong>내일부터</strong> 예약할 수 있어요.</p>
          <div class="field">
            <label class="field-label" for="pickupDate">날짜</label>
            <input type="date" id="pickupDate" name="pickupDate" class="date-input"
                   min="<%= minDate %>" max="<%= maxDate %>" value="<%= minDate %>" required>
          </div>
          <div class="field">
            <span class="field-label" id="timeLabel">시간</span>
            <div class="choice-row" role="radiogroup" aria-labelledby="timeLabel">
              <% for (int i = 0; i < times.size(); i++) { String t = times.get(i); %>
                <label class="choice">
                  <input type="radio" name="pickupTime" value="<%= t %>" <%= i == 3 ? "checked" : "" %> required>
                  <span><%= t %></span>
                </label>
              <% } %>
            </div>
          </div>
        </section>

        <!-- 2. 결제 수단 (모의) -->
        <section class="order-box">
          <h2 class="order-box-title"><span class="step-badge">2</span>결제 수단</h2>
          <p class="order-box-hint">과제용 <strong>모의 결제</strong>예요. 실제로 돈이 나가지 않아요.</p>
          <div class="choice-row">
            <% boolean first = true; for (Map.Entry<String, String> p : pays.entrySet()) { %>
              <label class="choice pay-choice">
                <input type="radio" name="payMethod" value="<%= p.getKey() %>" <%= first ? "checked" : "" %> required>
                <span><%= HtmlUtil.escape(p.getValue()) %></span>
              </label>
            <% first = false; } %>
          </div>
        </section>

        <!-- 3. 주문자 -->
        <section class="order-box">
          <h2 class="order-box-title"><span class="step-badge">3</span>주문자</h2>
          <dl class="buyer-list">
            <dt>이름</dt><dd><%= HtmlUtil.escape(buyer.getName()) %></dd>
            <dt>연락처</dt><dd><%= buyer.getPhone() == null ? "-" : HtmlUtil.escape(buyer.getPhone()) %></dd>
          </dl>
        </section>

        <!-- 4. 주문 케이크 -->
        <section class="order-box">
          <h2 class="order-box-title"><span class="step-badge">4</span>주문 케이크 <small>(<%= items.size() %>건)</small></h2>
          <ul class="order-items">
            <% for (CartItem item : items) { %>
              <li class="order-item">
                <div class="order-thumb">
                  <% if (item.getImageUrl() != null) { %><img src="<%= ctx + item.getImageUrl() %>" alt="" onerror="this.remove()"><% } %>
                </div>
                <div>
                  <p class="order-item-name"><%= HtmlUtil.escape(item.getProductName()) %> × <%= item.getQuantity() %></p>
                  <% if (item.getOptions() != null) { %><p class="order-item-sub"><%= HtmlUtil.escape(item.getOptions()) %></p><% } %>
                  <% if (item.getLettering() != null) { %><p class="order-item-lettering">"<%= HtmlUtil.escape(item.getLettering()) %>"</p><% } %>
                  <% if (item.getRequest() != null) { %><p class="order-item-sub">요청: <%= HtmlUtil.escape(item.getRequest()) %></p><% } %>
                </div>
                <p class="order-item-price"><%= HtmlUtil.won(item.getLineTotal()) %>원</p>
              </li>
            <% } %>
          </ul>
        </section>
      </div>

      <!-- 오른쪽: 결제 금액 -->
      <aside class="pay-summary">
        <h2>결제 금액</h2>
        <div class="pay-row"><span>상품 <%= items.size() %>건</span><strong><%= HtmlUtil.won(total) %>원</strong></div>
        <div class="pay-row"><span>픽업</span><strong>매장 방문 (무료)</strong></div>
        <div class="pay-row"><span>픽업 일시</span><strong id="pickupPreview">-</strong></div>
        <div class="pay-total"><span>합계</span><strong><%= HtmlUtil.won(total) %>원</strong></div>
        <label class="agree">
          <input type="checkbox" name="agree" value="Y" required>
          <span>주문 케이크의 옵션·레터링 문구와 픽업 일시를 확인했어요. (주문 제작 상품이라 제작 시작 후에는 바꿀 수 없어요)</span>
        </label>
        <button type="submit" class="btn btn-orange btn-block" id="payBtn"><%= HtmlUtil.won(total) %>원 결제하기</button>
        <a href="<%= ctx %>/cart" class="btn btn-block">장바구니로 돌아가기</a>
        <p class="mock-note">💳 모의 결제 · 실제 결제는 이루어지지 않아요</p>
      </aside>
    </form>
  </main>

  <jsp:include page="/common/footer.jsp" />
  <script>
    (function () {
      var form = document.getElementById('checkoutForm');
      var date = document.getElementById('pickupDate');
      var preview = document.getElementById('pickupPreview');
      var days = ['일', '월', '화', '수', '목', '금', '토'];

      // 오른쪽 상자에 고른 픽업 일시 보여주기
      function update() {
        var t = form.querySelector('input[name="pickupTime"]:checked');
        if (!date.value || !t) { preview.textContent = '-'; return; }
        var d = new Date(date.value + 'T00:00:00');
        preview.textContent = (d.getMonth() + 1) + '월 ' + d.getDate() + '일 (' + days[d.getDay()] + ') ' + t.value;
      }
      form.addEventListener('change', update);
      update();

      // 결제하기를 두 번 누르지 않게 버튼 잠그기
      form.addEventListener('submit', function () {
        var btn = document.getElementById('payBtn');
        btn.disabled = true;
        btn.textContent = '결제 진행 중…';
      });
    })();
  </script>
</body>
</html>
