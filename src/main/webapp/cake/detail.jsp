<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List, com.minecake.dto.*, com.minecake.controller.CakeServlet, com.minecake.util.HtmlUtil" %>
<%--
  cake/detail.jsp — 상품 상세 (예지)
  데이터: CakeServlet(GET /cake?id=번호)이 넣어 보내줌
    product  : 상품 기본 정보
    images   : 사진 여러 장 (대표 · 옆모습 · 위에서)
    info     : 원재료·원산지·영양성분·알레르기·보관 (없으면 null)
    showcase : 다른 고객님들의 커스텀 사진 후기
  - 케이크: "커스텀 주문하기" → cake/custom.jsp?id=번호 (소은: 옵션 선택·레터링 미리보기)
  - 추가 상품: 수량 고르고 바로 장바구니 담기 (CartServlet)
--%>
<%
    String ctx = request.getContextPath();
    Product p = (Product) request.getAttribute("product");
    if (p == null) {
        String id = request.getParameter("id");
        response.sendRedirect(ctx + "/cake" + (id != null ? "?id=" + java.net.URLEncoder.encode(id, "UTF-8") : ""));
        return;
    }
    @SuppressWarnings("unchecked")
    List<ProductImage> images = (List<ProductImage>) request.getAttribute("images");
    ProductInfo info = (ProductInfo) request.getAttribute("info");
    @SuppressWarnings("unchecked")
    List<CustomShowcase> showcase = (List<CustomShowcase>) request.getAttribute("showcase");

    boolean isCake = "CAKE".equals(p.getType());
    String categoryName = p.getCategory() == null ? null : CakeServlet.CATEGORIES.get(p.getCategory());
    String firstLetter = HtmlUtil.escape(p.getName().substring(0, 1));

    // 사진이 따로 등록 안 된 상품은 대표 사진(product.image_url) 1장만
    if ((images == null || images.isEmpty()) && p.getImageUrl() != null) {
        ProductImage main = new ProductImage();
        main.setViewType("MAIN");
        main.setImageUrl(p.getImageUrl());
        images = java.util.Collections.singletonList(main);
    }
    String mainUrl = (images != null && !images.isEmpty()) ? images.get(0).getImageUrl() : null;
    String mainLabel = (images != null && !images.isEmpty()) ? images.get(0).getViewLabel() : "대표 사진";
%>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title><%= HtmlUtil.escape(p.getName()) %> | Mine Cake</title>
  <link rel="stylesheet" href="<%= ctx %>/css/common.css">
  <link rel="stylesheet" href="<%= ctx %>/css/header.css">
  <link rel="stylesheet" href="<%= ctx %>/css/footer.css">
  <link rel="stylesheet" href="<%= ctx %>/css/cake.css">
</head>
<body>
  <jsp:include page="/common/header.jsp" />

  <main class="container detail-page">
    <nav class="breadcrumb" aria-label="현재 위치">
      <a href="<%= ctx %>/cake<%= isCake ? "" : "?type=ADDON" %>"><%= isCake ? "메인 케이크" : "추가 상품" %></a>
      <% if (categoryName != null) { %>
        <span>›</span><a href="<%= ctx %>/cake?category=<%= p.getCategory() %>"><%= categoryName %></a>
      <% } %>
    </nav>

    <div class="detail-layout">
      <!-- ================= 왼쪽: 사진 갤러리 (대표 · 옆모습 · 위에서) ================= -->
      <div class="gallery">
        <div class="detail-photo" id="galleryPhoto" data-src="<%= mainUrl == null ? "" : ctx + mainUrl %>" data-label="<%= mainLabel %>">
          <% if (p.getBest()) { %><span class="best-badge">Best</span><% } %>
          <span class="thumb-fallback" aria-hidden="true"><%= firstLetter %></span>
          <% if (mainUrl != null) { %>
            <img id="galleryMain" src="<%= ctx + mainUrl %>" alt="<%= HtmlUtil.escape(p.getName()) %> <%= mainLabel %>" onerror="this.style.visibility='hidden'">
          <% } %>
          <span class="photo-label" id="galleryLabel"><%= mainLabel %></span>
          <!-- 사진을 누르면 크게 보기 -->
          <button type="button" class="photo-zoom" id="photoZoomBtn" aria-label="사진 크게 보기">
            <span class="photo-zoom-hint">
              <svg viewBox="0 0 24 24" aria-hidden="true"><circle cx="10.5" cy="10.5" r="6.5" fill="none" stroke="currentColor" stroke-width="2"/><path d="M15.5 15.5L21 21M10.5 7.5v6M7.5 10.5h6" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"/></svg>
              크게 보기
            </span>
          </button>
        </div>

        <% if (images != null && images.size() > 1) { %>
          <div class="gallery-thumbs" role="tablist" aria-label="사진 보기">
            <% for (int i = 0; i < images.size(); i++) {
                   ProductImage img = images.get(i); %>
              <button type="button" class="gallery-thumb <%= i == 0 ? "active" : "" %>"
                      data-src="<%= ctx + img.getImageUrl() %>" data-label="<%= img.getViewLabel() %>"
                      aria-label="<%= img.getViewLabel() %> 보기">
                <span class="thumb-fallback" aria-hidden="true"><%= firstLetter %></span>
                <img src="<%= ctx + img.getImageUrl() %>" alt="" onerror="this.remove()">
                <span class="thumb-caption"><%= img.getViewLabel() %></span>
              </button>
            <% } %>
          </div>
        <% } %>
      </div>

      <!-- 사진 크게 보기 팝업 (대표 · 옆모습 · 위에서 사진을 좌우로 넘겨 보기) -->
      <dialog class="lightbox" id="lightbox" aria-label="사진 크게 보기">
        <button type="button" class="lightbox-close" id="lightboxClose" aria-label="닫기">&#10005;</button>
        <button type="button" class="lightbox-nav prev" id="lightboxPrev" aria-label="이전 사진">&#10094;</button>
        <figure class="lightbox-figure">
          <div class="lightbox-photo">
            <span class="thumb-fallback" aria-hidden="true"><%= firstLetter %></span>
            <img id="lightboxImg" src="" alt="">
          </div>
          <figcaption>
            <strong><%= HtmlUtil.escape(p.getName()) %></strong>
            <span id="lightboxCaption"></span>
            <span class="lightbox-count" id="lightboxCount"></span>
          </figcaption>
        </figure>
        <button type="button" class="lightbox-nav next" id="lightboxNext" aria-label="다음 사진">&#10095;</button>
      </dialog>

      <!-- ================= 오른쪽: 구매 정보 ================= -->
      <section class="detail-info">
        <% if (categoryName != null) { %><span class="product-cat"><%= categoryName %></span><% } %>
        <h1 class="detail-name"><%= HtmlUtil.escape(p.getName()) %></h1>
        <p class="detail-price">&#8361; <%= HtmlUtil.won(p.getPrice()) %><%= isCake ? " ~" : "" %></p>
        <% if (p.getDescription() != null) { %>
          <p class="detail-desc"><%= HtmlUtil.escape(p.getDescription()) %></p>
        <% } %>

        <% if (info != null && !info.getAllergenList().isEmpty()) { %>
          <p class="allergen-line">
            <span class="allergen-title">알레르기</span>
            <% for (String a : info.getAllergenList()) { %><span class="allergen-chip"><%= HtmlUtil.escape(a) %></span><% } %>
          </p>
        <% } %>

        <% if (isCake) { %>
          <ul class="detail-points">
            <li><strong>크기</strong> 도시락 · 1호 · 2호 중 선택</li>
            <li><strong>맛·크림 색·장식</strong> 커스텀 화면에서 선택</li>
            <li><strong>레터링</strong> 10자까지 무료, 20자까지 가능 (+1,000원)</li>
            <li><strong>픽업</strong> 날짜와 시간을 골라 매장에서 받아요</li>
          </ul>
          <div class="detail-actions">
            <a href="<%= ctx %>/cake/custom.jsp?id=<%= p.getProductId() %>" class="btn btn-orange btn-block">커스텀 주문하기</a>
            <a href="<%= ctx %>/ai/aiCake.jsp" class="btn btn-block">AI에게 디자인 추천받기</a>
          </div>
          <p class="detail-note">표시된 가격은 도시락 크기 기본가예요. 옵션에 따라 금액이 달라져요.</p>
        <% } else { %>
          <form method="post" action="<%= ctx %>/cart" class="addon-form">
            <input type="hidden" name="action" value="add">
            <input type="hidden" name="productId" value="<%= p.getProductId() %>">
            <label for="quantity">수량</label>
            <input type="number" id="quantity" name="quantity" value="1" min="1" max="10">
            <button type="submit" class="btn btn-orange btn-block">장바구니 담기</button>
          </form>
        <% } %>
      </section>
    </div>

    <% if (info != null) { %>
    <!-- ================= 원재료·원산지 / 영양정보 ================= -->
    <section class="detail-section" id="ingredients">
      <h2 class="detail-section-title">원재료·원산지</h2>
      <div class="info-grid">
        <% if (!info.getIngredientRows().isEmpty()) { %>
          <div class="info-table-wrap">
            <table class="info-table">
              <thead><tr><th scope="col">재료</th><th scope="col">원산지·특징</th></tr></thead>
              <tbody>
                <% for (String[] row : info.getIngredientRows()) { %>
                  <tr><th scope="row"><%= HtmlUtil.escape(row[0]) %></th><td><%= HtmlUtil.escape(row[1]) %></td></tr>
                <% } %>
              </tbody>
            </table>
          </div>
        <% } %>

        <% if (info.hasNutrition()) { %>
          <div class="nutrition-card">
            <div class="nutrition-head">
              <strong>영양정보</strong>
              <span><%= info.getServingBasis() == null ? "" : HtmlUtil.escape(info.getServingBasis()) %></span>
            </div>
            <% if (info.getKcal() != null) { %>
              <div class="nutrition-kcal"><span>열량</span><strong><%= info.getKcal() %> kcal</strong></div>
            <% } %>
            <dl class="nutrition-list">
              <% if (info.getSugarG() != null) { %><div><dt>당류</dt><dd><%= info.getSugarG() %> g</dd></div><% } %>
              <% if (info.getProteinG() != null) { %><div><dt>단백질</dt><dd><%= info.getProteinG() %> g</dd></div><% } %>
              <% if (info.getFatG() != null) { %><div><dt>지방</dt><dd><%= info.getFatG() %> g</dd></div><% } %>
              <% if (info.getSatFatG() != null) { %><div class="sub"><dt>포화지방</dt><dd><%= info.getSatFatG() %> g</dd></div><% } %>
              <% if (info.getSodiumMg() != null) { %><div><dt>나트륨</dt><dd><%= info.getSodiumMg() %> mg</dd></div><% } %>
            </dl>
            <p class="nutrition-note">도시락 크기 기본 옵션 기준이에요. 맛·크림 옵션에 따라 달라질 수 있어요.</p>
          </div>
        <% } %>
      </div>

      <% if (info.getStorage() != null) { %>
        <p class="storage-line"><strong>보관 방법</strong> <%= HtmlUtil.escape(info.getStorage()) %></p>
      <% } %>
    </section>
    <% } %>

    <% if (isCake) { %>
    <!-- ================= 다른 고객님들의 커스텀 ================= -->
    <section class="detail-section" id="showcase">
      <h2 class="detail-section-title">다른 고객님들은 이렇게 커스텀했어요</h2>
      <p class="detail-section-sub">픽업을 마친 고객님들이 남긴 사진 후기예요. 눌러서 크게 볼 수 있어요.</p>

      <% if (showcase == null || showcase.isEmpty()) { %>
        <div class="showcase-empty">
          <p>아직 이 케이크의 사진 후기가 없어요.</p>
          <p>첫 번째로 커스텀하고 후기를 남겨 주세요!</p>
        </div>
      <% } else { %>
        <ul class="showcase-grid">
          <% for (CustomShowcase c : showcase) { %>
            <li>
              <button type="button" class="showcase-card"
                      data-src="<%= c.getImageUrl() == null ? "" : ctx + c.getImageUrl() %>"
                      data-lettering="<%= HtmlUtil.escape(c.getLettering()) %>"
                      data-options="<%= HtmlUtil.escape(c.getOptions()) %>"
                      data-content="<%= HtmlUtil.escape(c.getContent()) %>"
                      data-writer="<%= HtmlUtil.escape(c.getMaskedWriter()) %>"
                      data-rating="<%= c.getRating() %>">
                <div class="showcase-photo">
                  <span class="thumb-fallback" aria-hidden="true"><%= firstLetter %></span>
                  <img src="<%= ctx + c.getImageUrl() %>" alt="<%= HtmlUtil.escape(c.getMaskedWriter()) %> 님의 커스텀 케이크" loading="lazy" onerror="this.remove()">
                </div>
                <div class="showcase-body">
                  <% if (c.getLettering() != null) { %>
                    <p class="showcase-lettering">"<%= HtmlUtil.escape(c.getLettering()) %>"</p>
                  <% } %>
                  <% if (c.getOptions() != null) { %>
                    <p class="showcase-options"><%= HtmlUtil.escape(c.getOptions()) %></p>
                  <% } %>
                  <p class="showcase-meta">
                    <span class="stars" aria-label="별점 <%= c.getRating() %>점"><% for (int s = 1; s <= 5; s++) { %><span class="<%= s <= c.getRating() ? "on" : "" %>">&#9733;</span><% } %></span>
                    <span><%= HtmlUtil.escape(c.getMaskedWriter()) %></span>
                  </p>
                </div>
              </button>
            </li>
          <% } %>
        </ul>
      <% } %>
    </section>

    <!-- 사진 크게 보기 창 -->
    <dialog class="showcase-dialog" id="showcaseDialog" aria-label="고객 커스텀 크게 보기">
      <div class="dialog-photo">
        <span class="thumb-fallback" aria-hidden="true"><%= firstLetter %></span>
        <img id="dialogImg" src="" alt="">
      </div>
      <div class="dialog-body">
        <p class="showcase-lettering" id="dialogLettering"></p>
        <p class="showcase-options" id="dialogOptions"></p>
        <p class="dialog-content" id="dialogContent"></p>
        <p class="showcase-meta"><span class="stars" id="dialogStars"></span><span id="dialogWriter"></span></p>
        <button type="button" class="btn btn-block" id="dialogClose">닫기</button>
      </div>
    </dialog>
    <% } %>
  </main>

  <jsp:include page="/common/footer.jsp" />
  <script src="<%= ctx %>/js/detail.js"></script>
</body>
</html>
