<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List, java.util.Map, com.minecake.dto.Product, com.minecake.controller.CakeServlet, com.minecake.util.HtmlUtil" %>
<%
    String ctx = request.getContextPath();
    String type = (String) request.getAttribute("type");
    if (type == null) {
        response.sendRedirect(ctx + "/cake");
        return;
    }
    boolean isCake = "CAKE".equals(type);
    String category = (String) request.getAttribute("category");
    if (category == null) category = "";
    String sort = (String) request.getAttribute("sort");
    if (sort == null) sort = "";

    @SuppressWarnings("unchecked")
    List<Product> products = (List<Product>) request.getAttribute("products");
    boolean isSeasonSelected = "SEASON".equals(category) || category.startsWith("SEASON_");
    String sortSuffix = sort.isEmpty() ? "" : "&sort=" + sort;
%>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title><%= isCake ? "메인 케이크" : "추가 상품" %> | Mine Cake</title>
  <link rel="stylesheet" href="<%= ctx %>/css/common.css">
  <link rel="stylesheet" href="<%= ctx %>/css/header.css">
  <link rel="stylesheet" href="<%= ctx %>/css/footer.css">
  <link rel="stylesheet" href="<%= ctx %>/css/cake.css">
  <style>
    .sub-category-tabs {
      display: flex;
      flex-wrap: wrap;
      gap: 6px;
      margin: -2px 0 18px;
      padding: 12px 16px;
      border-radius: 12px;
      background: var(--paper);
      border: 1px dashed var(--line);
    }
    .sub-category-tabs a {
      padding: 5px 13px;
      border-radius: 999px;
      border: 1px solid var(--line);
      background: var(--cream);
      font-size: var(--fs-sm);
      font-weight: 600;
      color: var(--ink-soft);
      transition: all .15s;
    }
    .sub-category-tabs a:hover { border-color: var(--ink); color: var(--ink); }
    .sub-category-tabs a.active {
      background: var(--orange);
      border-color: var(--orange);
      color: var(--on-accent);
    }
  </style>
</head>
<body>
  <jsp:include page="/common/header.jsp" />

  <main class="container shop-page">
    <h1 class="section-title"><%= isCake ? "메인 케이크" : "추가 상품" %></h1>
    <p class="section-sub">
      <%= isCake ? "마음에 드는 디자인을 고르고 나만의 문구를 넣어 보세요" : "케이크와 함께 곁들일 숫자초·토퍼·잡화를 골라 보세요" %>
    </p>

    <!-- ================= 1차 카테고리 탭 + 정렬 ================= -->
    <div class="shop-toolbar">
      <% if (isCake) { %>
        <nav class="category-tabs" aria-label="케이크 카테고리">
          <a href="<%= ctx %>/cake<%= sort.isEmpty() ? "" : "?sort=" + sort %>"
             class="<%= category.isEmpty() ? "active" : "" %>">전체</a>
          <% for (Map.Entry<String, String> entry : CakeServlet.CATEGORIES.entrySet()) {
               String code = entry.getKey();
               String label = entry.getValue();
               boolean active = code.equals(category) || ("SEASON".equals(code) && isSeasonSelected);
          %>
            <a href="<%= ctx %>/cake?category=<%= code %><%= sortSuffix %>"
               class="<%= active ? "active" : "" %>"><%= label %></a>
          <% } %>
        </nav>
      <% } else { %>
        <div></div>
      <% } %>

      <form method="get" action="<%= ctx %>/cake" class="sort-form">
        <% if (!isCake) { %><input type="hidden" name="type" value="ADDON"><% } %>
        <% if (!category.isEmpty()) { %><input type="hidden" name="category" value="<%= category %>"><% } %>
        <label for="sortSelect" class="sr-only">정렬 기준</label>
        <select id="sortSelect" name="sort" onchange="this.form.submit()">
          <% for (Map.Entry<String, String> entry : CakeServlet.SORTS.entrySet()) { %>
            <option value="<%= entry.getKey() %>" <%= entry.getKey().equals(sort) ? "selected" : "" %>>
              <%= entry.getValue() %>
            </option>
          <% } %>
        </select>
      </form>
    </div>

    <!-- ================= 2차 시즌 세부 카테고리 (시즌 선택 시 노출) ================= -->
    <% if (isCake && isSeasonSelected) { %>
      <nav class="sub-category-tabs" aria-label="시즌 세부 카테고리">
        <a href="<%= ctx %>/cake?category=SEASON<%= sortSuffix %>"
           class="<%= "SEASON".equals(category) ? "active" : "" %>">시즌 전체</a>
        <% for (Map.Entry<String, String> entry : CakeServlet.SEASON_CATEGORIES.entrySet()) {
             String sCode = entry.getKey();
             String sLabel = entry.getValue();
        %>
          <a href="<%= ctx %>/cake?category=<%= sCode %><%= sortSuffix %>"
             class="<%= sCode.equals(category) ? "active" : "" %>"><%= sLabel %></a>
        <% } %>
      </nav>
    <% } %>

    <p class="shop-count">상품 <strong><%= products == null ? 0 : products.size() %></strong>개</p>

    <!-- ================= 상품 목록 그리드 ================= -->
    <% if (products == null || products.isEmpty()) { %>
      <div class="shop-empty">
        <p class="shop-empty-title">아직 등록된 상품이 없어요</p>
        <a href="<%= ctx %>/cake<%= isCake ? "" : "?type=ADDON" %>" class="btn">전체 상품 보기</a>
      </div>
    <% } else { %>
      <ul class="product-grid">
        <% for (Product p : products) {
             String catLabel = CakeServlet.getCategoryLabel(p.getCategory());
             String firstLetter = HtmlUtil.escape(p.getName().substring(0, 1));
        %>
          <li>
            <a href="<%= ctx %>/cake?id=<%= p.getProductId() %>" class="product-card">
              <div class="product-thumb">
                <% if (p.getBest()) { %><span class="best-badge">Best</span><% } %>
                <span class="thumb-fallback" aria-hidden="true"><%= firstLetter %></span>
                <% if (p.getImageUrl() != null) { %>
                  <img src="<%= ctx + p.getImageUrl() %>" alt="<%= HtmlUtil.escape(p.getName()) %>" loading="lazy" onerror="this.remove()">
                <% } %>
              </div>
              <div class="product-info">
                <% if (catLabel != null) { %><span class="product-cat"><%= catLabel %></span><% } %>
                <strong class="product-name"><%= HtmlUtil.escape(p.getName()) %></strong>
                <span class="product-price">&#8361; <%= HtmlUtil.won(p.getPrice()) %><%= isCake ? " ~" : "" %></span>
                <% if (p.getReviewCount() > 0) { %>
                  <span class="product-review">리뷰 <%= p.getReviewCount() %></span>
                <% } %>
              </div>
            </a>
          </li>
        <% } %>
      </ul>
    <% } %>
  </main>

  <jsp:include page="/common/footer.jsp" />
</body>
</html>