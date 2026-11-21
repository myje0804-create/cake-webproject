<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.*, java.sql.*, com.minecake.dao.OptionDAO, com.minecake.dto.ProductOption, com.minecake.util.DBUtil, com.minecake.util.HtmlUtil" %>
<%--
  cart/addTest.jsp — 🔧 개발용 테스트 페이지 (역할 B)
  상품 상세·커스텀 화면(역할 A)이 완성되기 전에 "장바구니 담기 → 금액 계산 → 저장"을 확인하는 용도.
  ⚠ 발표 전에 삭제할 것. 메뉴에는 연결하지 않음.

  역할 A 참고: 이 폼이 CartServlet이 받는 이름(action, productId, optionId, lettering, request, quantity) 그대로예요.
--%>
<%
    String ctx = request.getContextPath();

    // 상품 목록 (테스트용이라 JSP에서 바로 조회)
    List<String[]> products = new ArrayList<>();
    Map<String, List<ProductOption>> groups = new LinkedHashMap<>();
    try {
    try (Connection conn = DBUtil.getConnection();
         PreparedStatement ps = conn.prepareStatement("SELECT product_id, type, name, price FROM product ORDER BY product_id");
         ResultSet rs = ps.executeQuery()) {
        while (rs.next()) {
            products.add(new String[] { rs.getString(1), rs.getString(2), rs.getString(3), String.format("%,d", rs.getInt(4)) });
        }
    }

    // 옵션을 종류별로 묶기
    for (ProductOption o : new OptionDAO().findAll()) {
        groups.computeIfAbsent(o.getOptionType(), k -> new ArrayList<>()).add(o);
    }
    } catch (SQLException e) {
        throw new ServletException("DB 조회 실패: MySQL과 DBUtil 비밀번호를 확인하세요.", e);
    }
    Map<String, String> typeNames = new HashMap<>();
    typeNames.put("SIZE", "크기");
    typeNames.put("FLAVOR", "맛");
    typeNames.put("CREAM_COLOR", "크림 색");
    typeNames.put("DECO", "장식");
%>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>장바구니 담기 테스트 | Mine Cake</title>
  <link rel="stylesheet" href="<%= ctx %>/css/common.css">
  <link rel="stylesheet" href="<%= ctx %>/css/header.css">
  <link rel="stylesheet" href="<%= ctx %>/css/footer.css">
  <link rel="stylesheet" href="<%= ctx %>/css/member.css">
  <style>
    .test-card { max-width: 560px; }
    .test-badge { display: inline-block; padding: 2px 10px; border-radius: 999px; background: #FDF0E6; color: #9A4A16; font-size: 12px; font-weight: 700; }
    fieldset { border: 1.5px solid var(--line); border-radius: 8px; margin: 14px 0 0; padding: 10px 14px; }
    legend { font-weight: 700; font-size: 14px; padding: 0 6px; }
    .opt { display: inline-flex; align-items: center; gap: 6px; margin: 4px 14px 4px 0; font-size: 14px; }
    .opt input { width: auto; }
    select { width: 100%; padding: 12px 14px; border: 1.5px solid var(--line); border-radius: 8px; background: var(--cream); font: inherit; }
  </style>
</head>
<body>
  <jsp:include page="/common/header.jsp" />

  <main class="container member-page">
    <section class="member-card test-card">
      <span class="test-badge">개발용 테스트 페이지</span>
      <h1 class="member-title">장바구니 담기 테스트</h1>
      <p class="member-sub">로그인한 상태에서 담아 보세요. 가격은 서버에서 계산돼요.</p>

      <form method="post" action="<%= ctx %>/cart" class="member-form">
        <input type="hidden" name="action" value="add">

        <label for="productId">상품</label>
        <select id="productId" name="productId">
          <% for (String[] p : products) { %>
            <option value="<%= p[0] %>">[<%= p[1] %>] <%= HtmlUtil.escape(p[2]) %> · <%= p[3] %>원</option>
          <% } %>
        </select>

        <% for (Map.Entry<String, List<ProductOption>> g : groups.entrySet()) { %>
          <fieldset>
            <legend><%= typeNames.getOrDefault(g.getKey(), g.getKey()) %></legend>
            <% boolean first = true;
               for (ProductOption o : g.getValue()) { %>
              <label class="opt">
                <input type="radio" name="optionId_<%= g.getKey() %>" value="<%= o.getOptionId() %>" <%= first ? "checked" : "" %>
                       onchange="syncOptions()">
                <%= HtmlUtil.escape(o.getName()) %><%= o.getExtraPrice() > 0 ? " (+" + HtmlUtil.won(o.getExtraPrice()) + "원)" : "" %>
              </label>
            <% first = false; } %>
          </fieldset>
        <% } %>
        <!-- 위에서 고른 라디오 값을 CartServlet이 받는 이름(optionId)으로 옮겨 담는 칸 -->
        <div id="optionIds"></div>

        <label for="lettering">레터링 (최대 20자, 10자 넘으면 +1,000원)</label>
        <input type="text" id="lettering" name="lettering" maxlength="20" value="Happy Birthday Yeji">

        <label for="request">요청사항</label>
        <input type="text" id="request" name="request" maxlength="200" placeholder="예: 초는 3개만 넣어 주세요">

        <label for="quantity">수량</label>
        <input type="number" id="quantity" name="quantity" value="1" min="1" max="10">

        <button type="submit" class="btn btn-orange btn-block">장바구니 담기</button>
      </form>
    </section>
  </main>

  <jsp:include page="/common/footer.jsp" />
  <script>
    // 종류별 라디오(optionId_SIZE 등)에서 고른 값을 optionId라는 같은 이름의 hidden 칸들로 만듦
    function syncOptions() {
      const box = document.getElementById('optionIds');
      box.innerHTML = '';
      document.querySelectorAll('input[type=radio][name^="optionId_"]:checked').forEach(function (r) {
        const h = document.createElement('input');
        h.type = 'hidden'; h.name = 'optionId'; h.value = r.value;
        box.appendChild(h);
      });
    }
    syncOptions();
  </script>
</body>
</html>
