<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*, java.util.ArrayList, java.util.List, com.minecake.util.DBUtil, com.minecake.util.HtmlUtil" %>
<%!
    public static class OptionItem {
        public int id;          // option_id — 장바구니로 보낼 옵션 번호
        public String name;
        public int extra;
        /** DB에 옵션이 없을 때 쓰는 기본값용 (번호 없음) */
        public OptionItem(String name, int extra) {
            this(0, name, extra);
        }
        public OptionItem(int id, String name, int extra) {
            this.id = id;
            this.name = name;
            this.extra = extra;
        }
    }
%>
<%
    String ctx = request.getContextPath();
    int productId = 11;
    try {
        String idParam = request.getParameter("id");
        if (idParam != null && !idParam.trim().isEmpty()) {
            productId = Integer.parseInt(idParam.trim());
        }
    } catch (NumberFormatException ignored) {}

    String productName = "나만의 커스텀 케이크";
    String productDesc = "원하는 크기와 맛, 크림 색상, 레터링 문구를 직접 조합해 보세요.";
    String productImg = "/images/cakes/couple_3.jpg";
    int basePrice = 28000;

    List<OptionItem> sizeOpts = new ArrayList<>();
    List<OptionItem> flavorOpts = new ArrayList<>();
    List<OptionItem> colorOpts = new ArrayList<>();
    List<OptionItem> decoOpts = new ArrayList<>();

    try (Connection conn = DBUtil.getConnection()) {
        // 1. 케이크 기본 정보 조회
        boolean found = false;
        try (PreparedStatement ps = conn.prepareStatement(
                "SELECT product_id, name, price, description, image_url FROM product WHERE product_id = ?")) {
            ps.setInt(1, productId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    found = true;
                    productId = rs.getInt("product_id");
                    productName = rs.getString("name");
                    basePrice = rs.getInt("price");
                    if (rs.getString("description") != null) productDesc = rs.getString("description");
                    if (rs.getString("image_url") != null) productImg = rs.getString("image_url");
                }
            }
        }

        // 해당 ID가 없으면 등록된 첫 번째 CAKE 상품 자동 조회
        if (!found) {
            try (PreparedStatement ps = conn.prepareStatement(
                    "SELECT product_id, name, price, description, image_url FROM product WHERE type = 'CAKE' ORDER BY product_id ASC LIMIT 1");
                 ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    productId = rs.getInt("product_id");
                    productName = rs.getString("name");
                    basePrice = rs.getInt("price");
                    if (rs.getString("description") != null) productDesc = rs.getString("description");
                    if (rs.getString("image_url") != null) productImg = rs.getString("image_url");
                }
            }
        }

        // 2. 커스텀 옵션 목록 조회 (SIZE / FLAVOR / CREAM_COLOR / DECO)
        try (PreparedStatement ps = conn.prepareStatement(
                "SELECT option_id, option_type, name, extra_price FROM product_option ORDER BY option_id ASC");
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                OptionItem item = new OptionItem(rs.getInt("option_id"), rs.getString("name"), rs.getInt("extra_price"));
                String type = rs.getString("option_type");
                if ("SIZE".equals(type)) sizeOpts.add(item);
                else if ("FLAVOR".equals(type)) flavorOpts.add(item);
                else if ("CREAM_COLOR".equals(type)) colorOpts.add(item);
                else if ("DECO".equals(type)) decoOpts.add(item);
            }
        }
    } catch (Exception e) {
        e.printStackTrace();
    }

    // DB에 옵션이 비어있을 경우 기본값 세팅
    if (sizeOpts.isEmpty()) {
        sizeOpts.add(new OptionItem("도시락 (1~2인)", 0));
        sizeOpts.add(new OptionItem("1호 (3~4인)", 10000));
        sizeOpts.add(new OptionItem("2호 (4~5인)", 18000));
    }
    if (flavorOpts.isEmpty()) {
        flavorOpts.add(new OptionItem("바닐라", 0));
        flavorOpts.add(new OptionItem("초코", 2000));
        flavorOpts.add(new OptionItem("얼그레이", 3000));
    }
    if (colorOpts.isEmpty()) {
        colorOpts.add(new OptionItem("화이트", 0));
        colorOpts.add(new OptionItem("파스텔 핑크", 0));
        colorOpts.add(new OptionItem("세이지 그린", 1000));
        colorOpts.add(new OptionItem("레몬 옐로우", 0));
    }
    if (decoOpts.isEmpty()) {
        decoOpts.add(new OptionItem("기본", 0));
        decoOpts.add(new OptionItem("구슬 테두리", 2000));
        decoOpts.add(new OptionItem("조개 테두리", 2000));
        decoOpts.add(new OptionItem("하트 펄", 3000));
    }
%>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>커스텀 주문 | <%= HtmlUtil.escape(productName) %> - Mine Cake</title>
  <link rel="stylesheet" href="<%= ctx %>/css/common.css">
  <link rel="stylesheet" href="<%= ctx %>/css/header.css">
  <link rel="stylesheet" href="<%= ctx %>/css/footer.css">
  <link rel="stylesheet" href="<%= ctx %>/css/cake.css">
  <style>
    .custom-page { padding-block: 44px 72px; }
    .custom-grid { display: grid; grid-template-columns: 1fr 1.15fr; gap: 44px; align-items: start; }
    @media (max-width: 860px) { .custom-grid { grid-template-columns: 1fr; } }

    /* 왼쪽 실시간 케이크 미리보기 (실제 케이크 사진 위에 선택 색상·문구 겹침 방식) */
    .preview-card {
      position: sticky; top: 96px;
      background: #FAF8F5; border: 1px solid #E5DDD3; border-radius: 18px; padding: 28px;
      text-align: center;
    }
    .preview-stage {
      position: relative; width: 100%; aspect-ratio: 1 / 1; max-width: 360px; margin: 0 auto 18px;
      border-radius: 16px; background: #F2EFE9; border: 1px solid #E6DFD5;
      overflow: hidden; box-shadow: 0 10px 24px rgba(44, 42, 41, 0.08);
    }
    /* 실제 케이크 사진 선명하게 표시 */
    .preview-stage img.base-photo {
      position: absolute; inset: 0; width: 100%; height: 100%; object-fit: cover;
      transition: transform 0.25s ease;
    }
    /* 선택한 크림 색상을 사진 위에 자연스럽게 겹치는 레이어 */
    .color-tint-overlay {
      position: absolute; inset: 0; z-index: 1;
      background-color: transparent;
      mix-blend-mode: multiply;
      pointer-events: none;
      transition: background-color 0.25s ease;
    }
    /* 케이크 사진 위에 겹쳐지는 레터링 & 테두리 장식 오버레이 */
    .cake-overlay-box {
      position: absolute; inset: 18px; z-index: 2; border-radius: 50%;
      border: 6px solid transparent;
      display: flex; flex-direction: column; align-items: center; justify-content: center;
      padding: 24px; pointer-events: none; transition: all 0.25s ease;
    }
    .cake-overlay-box.deco-bead {
      border-style: dotted; border-width: 9px; border-color: rgba(255, 253, 249, 0.9);
      box-shadow: inset 0 0 16px rgba(0, 0, 0, 0.08);
    }
    .cake-overlay-box.deco-shell {
      border-style: double; border-width: 10px; border-color: rgba(255, 253, 249, 0.9);
      box-shadow: inset 0 0 16px rgba(0, 0, 0, 0.08);
    }
    .cake-overlay-box.deco-heart::after {
      content: "♥   ♥   ♥"; position: absolute; bottom: 16px; font-size: 15px;
      color: #D9536F; text-shadow: 0 1px 4px rgba(255, 255, 255, 0.95); letter-spacing: 4px;
    }
    .cake-lettering-preview {
      font-family: Georgia, 'Nanum Myeongjo', serif; font-size: 19px; font-weight: 700;
      color: #3B2820; word-break: keep-all; line-height: 1.4; max-width: 220px;
      background: rgba(255, 253, 249, 0.84); backdrop-filter: blur(2px);
      padding: 8px 15px; border-radius: 12px;
      box-shadow: 0 3px 12px rgba(0, 0, 0, 0.14);
      transition: all 0.2s ease;
    }
    .cake-lettering-preview.is-placeholder {
      color: #7A6B63; font-weight: 600;
    }
    .preview-badges { display: flex; flex-wrap: wrap; gap: 6px; justify-content: center; margin-top: 10px; }
    .preview-badge {
      font-size: 12px; padding: 4px 10px; border-radius: 999px;
      background: #F2F4F0; color: #4A5D54; border: 1px solid #DCE3DD;
    }
    .preview-caption { font-size: 13px; color: #7A726B; margin-top: 12px; }

    /* 오른쪽 커스텀 옵션 폼 */
    .custom-form-box {
      background: #FFFFFF; border: 1px solid #EAE4DC; border-radius: 18px; padding: 32px;
    }
    .custom-title { font-size: 24px; font-weight: 700; color: #2C2A29; margin-bottom: 6px; }
    .custom-desc { font-size: 14px; color: #6E6761; margin-bottom: 24px; line-height: 1.5; }

    .opt-group { margin-bottom: 24px; padding-bottom: 20px; border-bottom: 1px solid #F1ECE6; }
    .opt-group:last-of-type { border-bottom: none; margin-bottom: 12px; }
    .opt-label { display: flex; justify-content: space-between; font-size: 15px; font-weight: 600; color: #2C2A29; margin-bottom: 10px; }
    .opt-hint { font-size: 12px; font-weight: 400; color: #8A8179; }
    .opt-hint.is-paid { color: #B57C84; font-weight: 600; }

    .opt-pills { display: flex; flex-wrap: wrap; gap: 8px; }
    .opt-pill {
      cursor: pointer; padding: 9px 15px; border-radius: 999px; font-size: 14px;
      background: #FAF8F5; border: 1px solid #DFD7CD; color: #3D3834;
      transition: all 0.15s ease; user-select: none;
    }
    .opt-pill:hover { border-color: #B57C84; }
    .opt-pill.active {
      background: #F5E6E8; border-color: #B57C84; color: #7A3E47; font-weight: 600;
    }

    .custom-input, .custom-select {
      width: 100%; padding: 11px 14px; border: 1px solid #DFD7CD; border-radius: 10px;
      font-size: 14px; color: #2C2A29; background: #FAF8F5; outline: none;
    }
    .custom-input:focus, .custom-select:focus {
      border-color: #B57C84; background: #FFFFFF;
    }
    .pickup-row { display: grid; grid-template-columns: 1fr 1fr; gap: 10px; }

    /* 합계 및 장바구니 버튼 */
    .price-summary {
      background: #FAF8F5; border: 1px solid #E5DDD3; border-radius: 14px; padding: 18px 20px;
      margin: 20px 0; display: flex; justify-content: space-between; align-items: center;
    }
    .price-summary span { font-size: 14px; color: #5C554F; }
    .price-summary strong { font-size: 22px; color: #B57C84; }
    .btn-submit-custom {
      width: 100%; padding: 15px; border: none; border-radius: 12px; font-size: 16px; font-weight: 700;
      background: #B57C84; color: #FFFFFF; cursor: pointer; transition: background 0.2s;
    }
    .btn-submit-custom:hover { background: #9E656D; }
  </style>
</head>
<body>
  <jsp:include page="/common/header.jsp" />

  <main class="container custom-page">
    <nav class="breadcrumb" aria-label="현재 위치">
      <a href="<%= ctx %>/cake">메인 케이크</a>
      <span>›</span><a href="<%= ctx %>/cake?id=<%= productId %>"><%= HtmlUtil.escape(productName) %></a>
      <span>›</span><span>커스텀 주문</span>
    </nav>

    <div class="custom-grid">
      <!-- ================= 왼쪽: 실시간 커스텀 미리보기 ================= -->
      <aside class="preview-card">
        <div class="preview-stage">
          <% if (productImg != null) { %>
            <img class="base-photo" src="<%= ctx + productImg %>" alt="<%= HtmlUtil.escape(productName) %>" onerror="this.remove()">
          <% } %>
          <div class="color-tint-overlay" id="colorTintOverlay"></div>
          <div class="cake-overlay-box" id="cakeMockup">
            <div class="cake-lettering-preview is-placeholder" id="letteringPreview">Happy Day</div>
          </div>
        </div>

        <div class="preview-badges" id="previewBadges">
          <span class="preview-badge" id="badgeSize"></span>
          <span class="preview-badge" id="badgeFlavor"></span>
          <span class="preview-badge" id="badgeColor"></span>
          <span class="preview-badge" id="badgeDeco"></span>
        </div>
        <p class="preview-caption">케이크 사진 위에 선택하신 크림 색상과 레터링 문구가 실시간으로 겹쳐 표시돼요.</p>
      </aside>

      <!-- ================= 오른쪽: 옵션 선택 및 주문 폼 ================= -->
      <section class="custom-form-box">
        <h1 class="custom-title"><%= HtmlUtil.escape(productName) %></h1>
        <p class="custom-desc"><%= HtmlUtil.escape(productDesc) %></p>

        <form method="post" action="<%= ctx %>/cart" id="customForm">
          <input type="hidden" name="action" value="add">
          <input type="hidden" name="productId" value="<%= productId %>">
          <input type="hidden" name="options" id="hiddenOptions" value="">
          <input type="hidden" name="price" id="hiddenPrice" value="<%= basePrice %>">
          <%-- 장바구니(CartServlet)는 옵션 번호(optionId)로 받아서 서버에서 금액을 다시 계산함 --%>
          <input type="hidden" name="optionId" id="optSize" value="">
          <input type="hidden" name="optionId" id="optFlavor" value="">
          <input type="hidden" name="optionId" id="optColor" value="">
          <input type="hidden" name="optionId" id="optDeco" value="">

          <!-- 1. 크기 선택 -->
          <div class="opt-group">
            <div class="opt-label"><span>1. 케이크 크기</span><span class="opt-hint">필수 선택</span></div>
            <div class="opt-pills" data-group="size">
              <% for (int i = 0; i < sizeOpts.size(); i++) {
                   OptionItem o = sizeOpts.get(i); %>
                <button type="button" class="opt-pill <%= i == 0 ? "active" : "" %>"
                        data-id="<%= o.id %>"
                        data-name="<%= HtmlUtil.escape(o.name) %>"
                        data-extra="<%= o.extra %>">
                  <%= HtmlUtil.escape(o.name) %><%= o.extra > 0 ? " (+" + HtmlUtil.won(o.extra) + "원)" : "" %>
                </button>
              <% } %>
            </div>
          </div>

          <!-- 2. 시트 맛 선택 -->
          <div class="opt-group">
            <div class="opt-label"><span>2. 시트 맛</span><span class="opt-hint">필수 선택</span></div>
            <div class="opt-pills" data-group="flavor">
              <% for (int i = 0; i < flavorOpts.size(); i++) {
                   OptionItem o = flavorOpts.get(i); %>
                <button type="button" class="opt-pill <%= i == 0 ? "active" : "" %>"
                        data-id="<%= o.id %>"
                        data-name="<%= HtmlUtil.escape(o.name) %>"
                        data-extra="<%= o.extra %>">
                  <%= HtmlUtil.escape(o.name) %><%= o.extra > 0 ? " (+" + HtmlUtil.won(o.extra) + "원)" : "" %>
                </button>
              <% } %>
            </div>
          </div>

          <!-- 3. 크림 색상 선택 -->
          <div class="opt-group">
            <div class="opt-label"><span>3. 크림 색상</span><span class="opt-hint">미리보기 반영</span></div>
            <div class="opt-pills" data-group="color">
              <% for (int i = 0; i < colorOpts.size(); i++) {
                   OptionItem o = colorOpts.get(i); %>
                <button type="button" class="opt-pill <%= i == 0 ? "active" : "" %>"
                        data-id="<%= o.id %>"
                        data-name="<%= HtmlUtil.escape(o.name) %>"
                        data-extra="<%= o.extra %>">
                  <%= HtmlUtil.escape(o.name) %><%= o.extra > 0 ? " (+" + HtmlUtil.won(o.extra) + "원)" : "" %>
                </button>
              <% } %>
            </div>
          </div>

          <!-- 4. 테두리·장식 디자인 -->
          <div class="opt-group">
            <div class="opt-label"><span>4. 테두리 장식 디자인</span><span class="opt-hint">미리보기 반영</span></div>
            <div class="opt-pills" data-group="deco">
              <% for (int i = 0; i < decoOpts.size(); i++) {
                   OptionItem o = decoOpts.get(i); %>
                <button type="button" class="opt-pill <%= i == 0 ? "active" : "" %>"
                        data-id="<%= o.id %>"
                        data-name="<%= HtmlUtil.escape(o.name) %>"
                        data-extra="<%= o.extra %>">
                  <%= HtmlUtil.escape(o.name) %><%= o.extra > 0 ? " (+" + HtmlUtil.won(o.extra) + "원)" : "" %>
                </button>
              <% } %>
            </div>
          </div>

          <!-- 5. 케이크 레터링 문구 -->
          <div class="opt-group">
            <div class="opt-label">
              <span>5. 케이크 레터링 문구</span>
              <span class="opt-hint" id="letteringCount">0 / 20자 (10자까지 무료)</span>
            </div>
            <input type="text" name="lettering" id="letteringInput" class="custom-input"
                   maxlength="20" placeholder="예: 생일 축하해 소은! (최대 20자)">
          </div>

          <!-- 6. 희망 픽업 날짜 및 시간 -->
          <div class="opt-group">
            <div class="opt-label"><span>6. 희망 픽업 날짜 · 시간</span><span class="opt-hint">매장 방문 수령</span></div>
            <div class="pickup-row">
              <input type="date" id="pickupDate" class="custom-input" required>
              <select id="pickupTime" class="custom-select" required>
                <option value="">픽업 시간 선택</option>
                <option value="11:00">11:00</option>
                <option value="12:00">12:00</option>
                <option value="13:00">13:00</option>
                <option value="14:00">14:00</option>
                <option value="15:00">15:00</option>
                <option value="16:00">16:00</option>
                <option value="17:00">17:00</option>
                <option value="18:00">18:00</option>
                <option value="19:00">19:00</option>
              </select>
            </div>
          </div>

          <!-- 7. 수량 및 추가 요청사항 -->
          <div class="opt-group">
            <div class="opt-label"><span>7. 수량 및 요청사항</span></div>
            <div style="display: grid; grid-template-columns: 110px 1fr; gap: 10px;">
              <input type="number" name="quantity" id="qtyInput" class="custom-input" value="1" min="1" max="10">
              <input type="text" name="request" id="requestInput" class="custom-input" placeholder="추가 요청사항이 있다면 적어주세요">
            </div>
          </div>

          <!-- 총 결제 예정 금액 -->
          <div class="price-summary">
            <span>선택 옵션 포함 총 금액</span>
            <strong id="totalPriceText"><%= HtmlUtil.won(basePrice) %>원</strong>
          </div>

          <button type="submit" class="btn-submit-custom">장바구니 담기</button>
        </form>
      </section>
    </div>
  </main>

  <jsp:include page="/common/footer.jsp" />

  <script>
    (function() {
      const basePrice = <%= basePrice %>;
      const mockup = document.getElementById('cakeMockup');
      const colorOverlay = document.getElementById('colorTintOverlay');
      const letteringInput = document.getElementById('letteringInput');
      const letteringPreview = document.getElementById('letteringPreview');
      const letteringCount = document.getElementById('letteringCount');
      const qtyInput = document.getElementById('qtyInput');
      const totalPriceText = document.getElementById('totalPriceText');
      const hiddenOptions = document.getElementById('hiddenOptions');
      const hiddenPrice = document.getElementById('hiddenPrice');
      const pickupDate = document.getElementById('pickupDate');
      const pickupTime = document.getElementById('pickupTime');

      const tomorrow = new Date(Date.now() + 86400000).toISOString().split('T')[0];
      pickupDate.min = tomorrow;
      pickupDate.value = tomorrow;

      // 크림 색상명 → 사진 위에 겹칠 반투명 색상 매핑
      const colorMap = {
        '화이트': 'transparent',
        '아이보리': 'rgba(255, 248, 225, 0.45)',
        '파스텔 핑크': 'rgba(255, 182, 193, 0.48)',
        '핑크': 'rgba(255, 182, 193, 0.48)',
        '세이지 그린': 'rgba(178, 211, 188, 0.50)',
        '민트': 'rgba(170, 232, 213, 0.48)',
        '하늘색': 'rgba(173, 216, 230, 0.50)',
        '스카이 블루': 'rgba(173, 216, 230, 0.50)',
        '레몬 옐로우': 'rgba(255, 238, 153, 0.50)',
        '옐로우': 'rgba(255, 238, 153, 0.50)',
        '라벤더': 'rgba(216, 191, 238, 0.50)',
        '초코': 'rgba(123, 88, 70, 0.52)'
      };

      function getSelected(groupName) {
        const active = document.querySelector('.opt-pills[data-group="' + groupName + '"] .opt-pill.active');
        return active ? {
          id: active.dataset.id || '',
          name: active.dataset.name,
          extra: parseInt(active.dataset.extra || '0', 10)
        } : { id: '', name: '', extra: 0 };
      }

      function updateAll() {
        const size = getSelected('size');
        const flavor = getSelected('flavor');
        const color = getSelected('color');
        const deco = getSelected('deco');
        const text = letteringInput.value.trim();
        const qty = Math.max(1, parseInt(qtyInput.value || '1', 10));

        // 1. 사진 위 색상 겹침 반영
        colorOverlay.style.backgroundColor = colorMap[color.name] || 'transparent';

        // 2. 사진 위 테두리 장식 반영
        mockup.classList.remove('deco-bead', 'deco-shell', 'deco-heart');
        if (deco.name.includes('구슬')) mockup.classList.add('deco-bead');
        else if (deco.name.includes('조개')) mockup.classList.add('deco-shell');
        else if (deco.name.includes('하트')) mockup.classList.add('deco-heart');

        // 3. 레터링 문구 및 글자 수 표시 반영
        if (text) {
          letteringPreview.textContent = text;
          letteringPreview.classList.remove('is-placeholder');
        } else {
          letteringPreview.textContent = 'Happy Day';
          letteringPreview.classList.add('is-placeholder');
        }

        const isPaidLettering = text.length > 10;
        letteringCount.textContent = text.length + ' / 20자' + (isPaidLettering ? ' (+1,000원 적용)' : ' (10자 초과 시 +1,000원)');
        letteringCount.classList.toggle('is-paid', isPaidLettering);

        // 4. 장바구니로 보낼 옵션 번호
        document.getElementById('optSize').value = size.id;
        document.getElementById('optFlavor').value = flavor.id;
        document.getElementById('optColor').value = color.id;
        document.getElementById('optDeco').value = deco.id;

        document.getElementById('badgeSize').textContent = size.name;
        document.getElementById('badgeFlavor').textContent = flavor.name;
        document.getElementById('badgeColor').textContent = color.name;
        document.getElementById('badgeDeco').textContent = deco.name;

        // 5. 총 금액 계산
        const letteringExtra = isPaidLettering ? 1000 : 0;
        const unitPrice = basePrice + size.extra + flavor.extra + color.extra + deco.extra + letteringExtra;
        const total = unitPrice * qty;

        totalPriceText.textContent = total.toLocaleString('ko-KR') + '원';
        hiddenPrice.value = unitPrice;

        const pickupStr = (pickupDate.value && pickupTime.value)
          ? ' | 픽업: ' + pickupDate.value + ' ' + pickupTime.value
          : '';
        hiddenOptions.value = [size.name, flavor.name, color.name, deco.name].filter(Boolean).join(' / ') + pickupStr;
      }

      document.querySelectorAll('.opt-pills').forEach(group => {
        group.addEventListener('click', e => {
          const btn = e.target.closest('.opt-pill');
          if (!btn) return;
          group.querySelectorAll('.opt-pill').forEach(b => b.classList.remove('active'));
          btn.classList.add('active');
          updateAll();
        });
      });

      letteringInput.addEventListener('input', updateAll);
      qtyInput.addEventListener('input', updateAll);
      pickupDate.addEventListener('change', updateAll);
      pickupTime.addEventListener('change', updateAll);

      updateAll();
    })();
    document.addEventListener("DOMContentLoaded", () => {
  const params = new URLSearchParams(location.search);
  const lettering = params.get("lettering");
  if (!lettering) return;

  const inputEl = document.getElementById("letteringInput");     // 실제 레터링 입력창 id로 변경
  const previewEl = document.getElementById("letteringPreview"); // 실제 미리보기 문구 id로 변경

  if (inputEl) {
    inputEl.value = lettering;
    inputEl.dispatchEvent(new Event("input", { bubbles: true }));
  }
  if (previewEl) {
    previewEl.textContent = lettering;
  }
});
  </script>
</body>
</html>