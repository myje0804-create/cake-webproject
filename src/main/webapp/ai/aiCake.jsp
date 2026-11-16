<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%--
  ai/aiCake.jsp — AI 케이크 추천
  할 일: ① 상황·받는 사람·분위기 입력 → AI 디자인·문구 추천 3개 → 커스텀 화면에 적용
  담당: 역할 C (README.md 역할 분담 참고)
--%>
<% String ctx = request.getContextPath(); %>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>AI 케이크 추천 | Mine Cake</title>
  <link rel="stylesheet" href="<%= ctx %>/css/common.css">
  <link rel="stylesheet" href="<%= ctx %>/css/header.css">
  <link rel="stylesheet" href="<%= ctx %>/css/footer.css">
</head>
<body>
  <jsp:include page="/common/header.jsp" />

  <main class="container" style="padding-block: 56px;">
    <h1 class="section-title">AI 케이크 추천</h1>
    <p class="section-sub">준비 중인 화면이에요. (① 상황·받는 사람·분위기 입력 → AI 디자인·문구 추천 3개 → 커스텀 화면에 적용)</p>
  </main>

  <jsp:include page="/common/footer.jsp" />
</body>
</html>
