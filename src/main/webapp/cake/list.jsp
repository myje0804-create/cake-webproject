<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List, java.util.Map, com.minecake.dto.Product, com.minecake.controller.CakeServlet, com.minecake.util.HtmlUtil" %>
<%--
  cake/list.jsp — ③ 메인 케이크 / ④ 추가 상품 목록 (예지)
  데이터: CakeServlet(GET /cake)이 products, type, category, sort를 넣어 보내줌
  ※ 주소창에서 이 파일을 바로 열면 데이터가 없으므로 /cake 로 다시 보냄
--%>
<%
    String ctx = request.getContextPath();
    @SuppressWarnings("unchecked")
    List<Product> products = (List<Product>) request.getAttribute("products");
    if (products == null) {
        response.sendRedirect(ctx + "/cake");
        return;
    }
    String type = (String) request.getAttribute("type");
    String category = (String) request.getAttribute("category");
    String sort = (String) request.getAttribute("sort");
    boolean isCake = "CAKE".equals(type);

    // 정렬을 바꿔도 카테고리는 유지되게, 카테고리를 바꿔도 정렬은 유지되게
    String sortQuery = sort.isEmpty() ? "" : "&sort=" + sort;
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
</head>
<body>
  <jsp:include page="/common/header.jsp" />

  <main class="container shop-page">
    <h1 class="section-title"><%= isCake ? "메인 케이크" : "추가 상품" %></h1>
    <p class="section-sub"><%= isCake ? "마음에 드는 디자인을 고르고 나만의 문구를 넣어 보세요" : "초·토퍼·케이크 칼을 함께 준비해 보세요" %></p>

    <!-- 카테고리 탭 + 정렬 -->
    <div class="shop-toolbar">
      <% if (isCake) { %>
        <nav class="category-tabs" aria-label="카테고리">
          <a href="<%= ctx %>/cake?<%= sortQuery.isEmpty() ? "" : sortQuery.substring(1) %>"
             class="<%= category.isEmpty() ? "active" : "" %>">전체</a>
          <% for (Map.Entry<String, String> c : CakeServlet.CATEGORIES.entrySet()) { %>
            <a href="<%= ctx %>/cake?category=<%= c.getKey() %><%= sortQuery %>"
               class="<%= c.getKey().equals(category) ? "active" : "" %>"><%= c.getValue() %></a>
          <% } %>
        </nav>
      <% } else { %>
        <div></div>
      <% } %>

      <form method="get" action="<%= ctx %>/cake" class="sort-form">
        <% if (!isCake) { %><input type="hidden" name="type" value="ADDON"><% } %>
        <% if (!category.isEmpty()) { %><input type="hidden" name="category" value="<%= category %>"><% } %>
        <label for="sort" class="sr-only">정렬</label>
        <select id="sort" name="sort" onchange="this.form.submit()">
          <% for (Map.Entry<String, String> s : CakeServlet.SORTS.entrySet()) { %>
            <option value="<%= s.getKey() %>" <%= s.getKey().equals(sort) ? "selected" : "" %>><%= s.getValue() %></option>
          <% } %>
        </select>
        <noscript><button type="submit" class="btn">정렬</button></noscript>
      </form>
    </div>

    <p class="shop-count">상품 <strong><%= products.size() %></strong>개</p>

    <% if (products.isEmpty()) { %>
      <section class="shop-empty">
        <p class="shop-empty-title">아직 이 카테고리에 상품이 없어요</p>
        <a href="<%= ctx %>/cake" class="btn">전체 케이크 보기</a>
      </section>
    <% } else { %>
      <ul class="product-grid">
        <% for (Product p : products) { %>
          <li>
            <a class="product-card" href="<%= ctx %>/cake?id=<%= p.getProductId() %>">
              <div class="product-thumb">
                <% if (p.getBest()) { %><span class="best-badge">Best</span><% } %>
                <span class="thumb-fallback" aria-hidden="true"><%= HtmlUtil.escape(p.getName().substring(0, 1)) %></span>
                <% if (p.getImageUrl() != null) { %>
                  <img src="<%= ctx + p.getImageUrl() %>" alt="<%= HtmlUtil.escape(p.getName()) %>" onerror="this.remove()">
                <% } %>
              </div>
              <div class="product-info">
                <% if (p.getCategory() != null && CakeServlet.CATEGORIES.containsKey(p.getCategory())) { %>
                  <span class="product-cat"><%= CakeServlet.CATEGORIES.get(p.getCategory()) %></span>
                <% } %>
                <span class="product-name"><%= HtmlUtil.escape(p.getName()) %></span>
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
