<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.io.*,java.sql.*,com.minecake.util.*,com.minecake.dao.*,com.minecake.dto.*,java.util.*" %>
<%--
  admin/productForm.jsp — 상품 등록·수정
  할 일: 상품 등록 / 수정 폼
  담당: 역할 C (README.md 역할 분담 참고)
--%>
<% String ctx = request.getContextPath(); %>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>상품 등록·수정 | Mine Cake</title>
  <link rel="stylesheet" href="<%= ctx %>/css/common.css">
  <link rel="stylesheet" href="<%= ctx %>/css/header.css">
  <link rel="stylesheet" href="<%= ctx %>/css/footer.css">
  <link rel="stylesheet" href="<%= ctx %>/css/admin.css">

</head>
<body>
  <jsp:include page="/common/header.jsp" />

  <main class="container" style="padding-block: 56px;">
    <h1 class="section-title">상품 등록</h1>
    <div class="registerCake">
      <form action="<%= ctx %>/admin/product" method="post" enctype="multipart/form-data" name="form1">
        <table width="680" border="0" cellpadding="0" cellspacing="0" id="registerform">
          <tr>
            <th><label for="type">* 유 형</label></th>
            <td><input name="type" type="text" id="type" size="70"></td>
          </tr>
          <tr>
            <th><label for="category">* 카테고리</label></th>
            <td><input name="category" type="text" id="category"></td>
          </tr>
          <tr>
            <th><label for="name">* 이름</label></th>
            <td><input name="name" type="text" id="name"></td>
          </tr>
          <tr>
            <th><label for="price">* 가격</label></th>
            <td><input name="price" type="text" id="price"></td>
          </tr>
          <tr>
            <th><label for="description">* 설명</label></th>
            <td><input name="description" type="text" id="description"></td>
          </tr>
          <tr>
            <th><label for="imageFile">* 케이크 이미지</label></th>
            <td><input name="imageFile" type="file" id="imageFile" accept="image/*"></td>
          </tr>
          <tr>
            <th><label for="folder">이미지가 들어갈 폴더</label></th>
            <td>
              <select name="folder" id="folder">
                <option value="cakes">cakes</option>
                <option value="addons">addons</option>
              </select>
            </td>
          </tr>
          <tr>
            <th>Best</th>
            <td>
              <label><input type="radio" name="best" value="true"> 예</label>
              <label><input type="radio" name="best" value="false" checked> 아니오</label>
            </td>
          </tr>
          <tr>
            <td height="30" colspan="2" align="center" class="btnstyle">
              <input type="submit" name="ok" id="ok" value="입력">
              <input type="reset" name="cancel" id="cancel" value="취소">
            </td>
          </tr>
        </table>
      </form>
    </div>
  </main>

  <jsp:include page="/common/footer.jsp" />
</body>
</html>
