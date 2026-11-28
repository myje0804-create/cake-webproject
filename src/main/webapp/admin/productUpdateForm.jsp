<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.io.*,java.sql.*,com.minecake.util.*,com.minecake.dao.*,com.minecake.dto.*,java.util.*" %>
<%--
  admin/productForm.jsp — 상품 등록·수정
  할 일: 상품 등록 / 수정 폼
  담당: 역할 C (README.md 역할 분담 참고)
--%>
<% String ctx = request.getContextPath(); %>
<%
  request.setCharacterEncoding("UTF-8");

  String idParam = request.getParameter("productId");
  Product product = null;
  if (idParam != null && !idParam.trim().isEmpty()) {
    int productId = Integer.parseInt(idParam.trim());
    Connection conn = null;
    try {
      conn = DBUtil.getConnection();
      ProductDAO dao = new ProductDAO();
      product = dao.selectById(conn, productId);
    } catch (SQLException e) {
      e.printStackTrace();
    } finally {
      if (conn != null) {
        try { conn.close(); } catch (SQLException ignored) {}
      }
    }
  }
  request.setAttribute("product", product);
%>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>상품 등록·수정 | Mine Cake</title>
  <link rel="stylesheet" href="<%= ctx %>/css/common.css">
  <link rel="stylesheet" href="<%= ctx %>/css/header.css">
  <link rel="stylesheet" href="<%= ctx %>/css/footer.css">
</head>
<body>
  <jsp:include page="/common/header.jsp" />

  <main class="container" style="padding-block: 56px;">
    <h1 class="section-title">상품 수정</h1>
    <div class="tablestyle">
      <form action="<%= ctx %>/admin/product" method="post" enctype="multipart/form-data" name="form1">
        <input type="hidden" name="oldImageUrl" value="${product.imageUrl}">

        <table width="680" border="0" cellpadding="0" cellspacing="0" id="registerform">
          <tr>
            <th><label for="productId">* 아이디</label></th>
            <td><input name="productId" id="productId" type="text" value="${product.productId}" size="70" readonly>
           </td>
          </tr>
          <tr>
            <th><label for="type">* 유 형</label></th>
            <td><input name="type" id="type" type="text" value="${product.type}" size="70"></td>
          </tr>
          <tr>
            <th><label for="category">* 카테고리</label></th>
            <td><input name="category" id="category" type="text" value="${product.category}"></td>
          </tr>
          <tr>
            <th><label for="name">* 이름</label></th>
            <td><input name="name" id="name" type="text" value="${product.name}"></td>
          </tr>
          <tr>
            <th><label for="price">* 가격</label></th>
            <td><input name="price" id="price" type="text" value="${product.price}"></td>
          </tr>
          <tr>
            <th><label for="description">* 설명</label></th>
            <td><input name="description" id="description" type="text" value="${product.description}"></td>
          </tr>
          <tr>
            <th><label for="imageFile">* 케이크 이미지</label></th>
            <td>
              <input name="imageFile" id="imageFile" type="file" accept="image/*">
              <br>현재 이미지: ${product.imageUrl} (새로 선택하지 않으면 유지됩니다)
            </td>
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
            <th>Best 상품</th>
            <td>
              <label><input type="radio" name="best" value="true"  ${product.best ? 'checked' : ''}> 예</label>
              <label><input type="radio" name="best" value="false" ${product.best ? '' : 'checked'}> 아니오</label>
            </td>
          </tr>
          <tr>
            <td height="30" colspan="2" align="center" class="btnstyle">
              <input type="submit" name="ok" id="ok" value="수정">
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
