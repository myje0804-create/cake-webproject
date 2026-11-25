<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%--
  index.jsp — 메인 화면
  구성: [배너 슬라이드] → [Best Design] → [⑦ 커스텀 주문 방법] → [⑧ 고객 후기]
--%>
<%
    String ctx = request.getContextPath();

    // 배너: { 이미지, 작은 글씨, 큰 글씨, 설명, 클릭 시 이동할 주소 }
    String[][] banners = {
        { "/images/cakes/design_12.jpg", "Handmade Custom Cake", "MINE CAKE",
          "세상에 하나뿐인 나만의 케이크를 만들어 보세요", "/cake" },
        { "/images/cakes/xmas_1.jpg", "Christmas Season", "크리스마스 케이크 예약",
          "12/1 ~ 12/20 사전 예약 시 숫자초 무료 증정", "/cake?category=SEASON_CHRISTMAS" },
        { "/images/cakes/couple_3.jpg", "Anniversary & Gift", "특별한 기념일 레터링",
          "소중한 사람에게 진심을 담은 디자인을 선물하세요", "/cake?category=COUPLE" }
    };

    // Best 케이크: { 상품번호, 이름, 시작가격, 이미지 }
    String[][] bestCakes = {
        { "11",  "+365 하트 물결 쉐입 케이크",            "28,000", "/images/cakes/couple_3.jpg" },
        { "32",  "리락쿠마 파티 도시락 케이크",           "21,000", "/images/cakes/birthday_1.jpg" },
        { "116", "진저브레드 과자집 입체 크리스마스 케이크", "42,000", "/images/cakes/xmas_1.jpg" }
    };

    // 고객 후기: { 별점(1~5), 케이크 이름, 후기 내용, 작성자, 사진 }
    String[][] reviews = {
        { "5", "+365 하트 물결 쉐입 케이크", "1주년 기념일에 주문했는데 사진이랑 똑같이 깔끔하고 너무 예뻐서 남자친구가 정말 좋아했어요!",
          "김*은", "/images/cakes/couple_3.jpg" },
        { "5", "리락쿠마 파티 도시락 케이크", "귀여운 캐릭터 디자인이 사진이랑 똑같았어요. 크림도 느끼하지 않고 촉촉해서 순삭했습니다!",
          "이*우", "/images/cakes/birthday_1.jpg" },
        { "5", "진저브레드 과자집 입체 크리스마스 케이크", "크리스마스 파티용으로 샀는데 디테일이 대박이에요. 사진 찍기 너무 예뻐서 다들 어디서 샀냐고 물어봤어요!",
          "박*지", "/images/cakes/xmas_1.jpg" }
    };
%>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Mine Cake | 주문 제작 커스텀 케이크</title>
  <link rel="stylesheet" href="<%= ctx %>/css/common.css">
  <link rel="stylesheet" href="<%= ctx %>/css/header.css">
  <link rel="stylesheet" href="<%= ctx %>/css/footer.css">
  <link rel="stylesheet" href="<%= ctx %>/css/main.css">
</head>
<body>

  <jsp:include page="/common/header.jsp" />

  <main>

    <!-- ================= 1. 메인 배너 (좌우 버튼으로 전환, 클릭 시 해당 페이지 이동) ================= -->
    <section class="banner" aria-label="메인 배너">
      <div class="banner-track" id="bannerTrack">
        <% for (int i = 0; i < banners.length; i++) { %>
          <a class="banner-slide <%= i == 0 ? "active" : "" %>" href="<%= ctx + banners[i][4] %>">
            <img src="<%= ctx + banners[i][0] %>" alt="" onerror="this.remove()">
            <div class="banner-text">
              <span class="banner-eyebrow"><%= banners[i][1] %></span>
              <strong class="banner-title"><%= banners[i][2] %></strong>
              <span class="banner-desc"><%= banners[i][3] %></span>
            </div>
          </a>
        <% } %>
      </div>

      <button type="button" class="banner-arrow prev" id="bannerPrev" aria-label="이전 배너">&#10094;</button>
      <button type="button" class="banner-arrow next" id="bannerNext" aria-label="다음 배너">&#10095;</button>

      <div class="banner-dots" id="bannerDots">
        <% for (int i = 0; i < banners.length; i++) { %>
          <button type="button" class="<%= i == 0 ? "active" : "" %>" aria-label="<%= i + 1 %>번 배너"></button>
        <% } %>
      </div>
    </section>

    <!-- ================= 2. Best Design (인기 케이크, 클릭 시 상세 페이지) ================= -->
    <section class="best container">
      <h2 class="section-title">Best Design</h2>
      <p class="section-sub">지금 가장 많이 주문하는 디자인이에요</p>

      <div class="best-grid">
        <% for (int i = 0; i < bestCakes.length; i++) { %>
          <a class="cake-card" href="<%= ctx %>/cake?id=<%= bestCakes[i][0] %>">
            <div class="cake-thumb">
              <% if (i == 0) { %><span class="best-badge">Best</span><% } %>
              <img src="<%= ctx + bestCakes[i][3] %>" alt="<%= bestCakes[i][1] %>" onerror="this.remove()">
            </div>
            <div class="cake-name"><%= bestCakes[i][1] %></div>
            <div class="cake-price">&#8361; <%= bestCakes[i][2] %> ~</div>
          </a>
        <% } %>
      </div>

      <div class="center-btn">
        <a href="<%= ctx %>/cake" class="btn">전체 케이크 보기</a>
      </div>
    </section>

    <!-- ================= 3. ⑦ 커스텀 주문 방법 소개 ================= -->
    <section class="howto">
      <div class="container">
        <h2 class="section-title">이렇게 주문해요</h2>
        <p class="section-sub">디자인부터 픽업까지, 4단계면 나만의 케이크 완성</p>

        <ol class="howto-steps">
          <li>
            <span class="step-no">1</span>
            <h3>디자인 고르기</h3>
            <p>Best 디자인이나 카테고리(커플·생일·부모님·시즌)에서 골라요</p>
          </li>
          <li>
            <span class="step-no">2</span>
            <h3>옵션 선택</h3>
            <p>크기·맛·크림 색상과 레터링 문구를 정해요</p>
          </li>
          <li>
            <span class="step-no">3</span>
            <h3>픽업 예약</h3>
            <p>원하는 날짜와 시간을 고르면 그 시간에 맞춰 만들어요</p>
          </li>
          <li>
            <span class="step-no">4</span>
            <h3>결제 &amp; 픽업</h3>
            <p>결제 후 마이페이지에서 제작 상태를 확인해요</p>
          </li>
        </ol>

        <div class="howto-cta">
          <a href="<%= ctx %>/cake" class="btn btn-orange">커스텀 주문 시작하기</a>
          <a href="<%= ctx %>/ai/aiCake.jsp" class="btn">AI에게 디자인 추천받기</a>
        </div>
      </div>
    </section>

    <!-- ================= 4. ⑧ 고객 후기 ================= -->
    <section class="reviews container">
      <h2 class="section-title">Review</h2>
      <p class="section-sub">직접 받아본 고객님들의 후기예요</p>

      <div class="review-grid">
        <% for (String[] r : reviews) {
               int star = Integer.parseInt(r[0]); %>
          <article class="review-card">
            <div class="review-photo">
              <img src="<%= ctx + r[4] %>" alt="<%= r[1] %> 후기 사진" onerror="this.remove()">
            </div>
            <div class="review-body">
              <div class="review-stars" aria-label="별점 <%= star %>점">
                <% for (int s = 1; s <= 5; s++) { %><span class="<%= s <= star ? "on" : "" %>">&#9733;</span><% } %>
              </div>
              <div class="review-cake"><%= r[1] %></div>
              <p class="review-text"><%= r[2] %></p>
              <div class="review-writer"><%= r[3] %></div>
            </div>
          </article>
        <% } %>
      </div>

      <div class="center-btn">
        <a href="<%= ctx %>/review/list.jsp" class="btn">후기 더보기</a>
      </div>
    </section>

  </main>

  <jsp:include page="/common/footer.jsp" />

  <script src="<%= ctx %>/js/banner.js"></script>
</body>
</html>