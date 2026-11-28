<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%--
  ai/aiCake.jsp — AI 케이크 추천
  할 일: ① 상황·받는 사람·분위기 입력 → AI 디자인·문구 추천 3개 → 커스텀 화면에 적용
  담당: 역할 C (README.md 역할 분담 참고)
--%>
<% String ctx = request.getContextPath(); %>
<%
    String product = (String) request.getAttribute("product");
    String answer = (String) request.getAttribute("answer");
    String error = (String) request.getAttribute("error");

    String cakeId = request.getParameter("id");
    if (cakeId == null || cakeId.isBlank()) {
        cakeId = (String) request.getAttribute("product_id");
    }
    if (cakeId == null || cakeId.isBlank()) {
        cakeId = (String) request.getAttribute("id");
    }

    if (product == null) product = "";
    if (answer == null) answer = "";
    if (error == null) error = "";
    if (cakeId == null) cakeId = "";
%>
<%!
    // 입력과 답변을 HTML에 안전하게 출력
 
    private String escapeHtml(String text) {
        if (text == null) return "";

        return text.replace("&", "&amp;")
                   .replace("<", "&lt;")
                   .replace(">", "&gt;")
                   .replace("\"", "&quot;")
                   .replace("'", "&#39;");
    }

%>

<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>AI 케이크 추천 | Mine Cake</title>
  <link rel="stylesheet" href="<%= ctx %>/css/common.css">
  <link rel="stylesheet" href="<%= ctx %>/css/header.css">
  <link rel="stylesheet" href="<%= ctx %>/css/footer.css">
  <link rel="stylesheet" href="<%= ctx %>/css/admin.css">
</head>
<body>
  <jsp:include page="/common/header.jsp" />

  <main class="container" style="padding-block: 56px;">
    <h1 class="aiSection-title">AI 케이크 추천</h1>
    <form method="post" action="<%= ctx %>/ai/recommend"
          onsubmit="document.getElementById('send').disabled=true;
                    document.getElementById('send').textContent='답변 생성 중…';">
    <input type="hidden" name="id" value="<%= escapeHtml(cakeId) %>">
      <%="예시 질문 목록입니다" %><br><br><hr>
      <%= "생일 케이크에 들어갈 문구를 3개만 추천해줘" %><br>
      <%= "크리스마스에 어울리는 케이크에 들어갈만한 디자인 1가지만 추천해줘" %><br>
      <%= "감사를 전하는 케이크에 들어갈 문구 추천해줘" %><br><hr><br>

      <textarea name="product"
                rows="5"
                placeholder="상황, 받는 사람, 분위기나 상품 정보를 입력해 주세요."
                required><%= escapeHtml(product) %></textarea>

      <div class="aibtn-style">
        <button id="aiSend" type="submit" style="width: 200px; height: 50px;">질문하기</button>
      </div>
    </form>

    <% if (!answer.isEmpty()) {
         String[] lines = answer.split("\\r?\\n");
         String customUrl = ctx + "/cake/custom.jsp"; // 실제 커스텀 페이지 경로에 맞게 수정
    %>
      <h3>minecake 답변</h3>
      <div class="aiAnswer-list">
        <% for (String rawLine : lines) {
             String cleanLine = rawLine.trim()
                     .replaceFirst("^([0-9]+[.)]|[-*•])\\s*", "")
                     .replaceAll("^[\"']|[\"']$", "")
                     .trim();
             if (cleanLine.isEmpty()) continue;
        %>
          <div class="aiAnswer-item">
            <span class="lettering-text"><%= escapeHtml(cleanLine) %></span>
            <div class="item-actions">
              <button type="button"
                      class="btn-copy"
                      data-text="<%= escapeHtml(cleanLine) %>"
                      onclick="copyLettering(this)">복사</button>
              <button type="button"
                      class="btn-apply"
                      data-text="<%= escapeHtml(cleanLine) %>"
                      onclick="applyToCustom(this)">커스텀 화면으로 이동</button>
            </div>
          </div>
        <% } %>
      </div>
    <% } %>

    <% if (!error.isEmpty()) { %>
      <div class="aiError"><%= escapeHtml(error) %></div>
    <% } %>
    <p class="section-sub">준비 중인 화면이에요. (① 상황·받는 사람·분위기 입력 → AI 디자인·문구 추천 3개 → 커스텀 화면에 적용)</p>
  </main>

  <jsp:include page="/common/footer.jsp" />
  <script>
    const CUSTOM_PAGE_URL = "<%= ctx %>/cake/custom.jsp"; // 실제 커스텀 화면 경로로 변경
    const CAKE_ID = "<%= escapeHtml(cakeId) %>";

    async function copyLettering(btn) {
      const text = btn.getAttribute("data-text");
      try {
        await navigator.clipboard.writeText(text);
        const original = btn.textContent;
        btn.textContent = "복사됨!";
        setTimeout(() => { btn.textContent = original; }, 1500);
      } catch (err) {
        const temp = document.createElement("textarea");
        temp.value = text;
        document.body.appendChild(temp);
        temp.select();
        document.execCommand("copy");
        document.body.removeChild(temp);
        alert("문구가 복사되었습니다: " + text);
      }
    }

    function applyToCustom(btn) {
      const text = btn.getAttribute("data-text");
      const params = new URLSearchParams();

      if (CAKE_ID) {
        params.append("id", CAKE_ID);
      }
      params.append("lettering", text);

      location.href = CUSTOM_PAGE_URL + "?" + params.toString();
    }
  </script>
</body>
</html>
