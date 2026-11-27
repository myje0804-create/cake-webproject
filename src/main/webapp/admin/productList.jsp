<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.io.*,java.sql.*,com.minecake.util.*,com.minecake.dao.*,com.minecake.dto.*,java.util.*" %>
<%--
  admin/productList.jsp — 상품 관리
  할 일: 상품 목록, Best 지정, 수정·삭제
  담당: 역할 C (README.md 역할 분담 참고)
--%>
<% String ctx = request.getContextPath(); %>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>상품 관리 | Mine Cake</title>
  <link rel="stylesheet" href="<%= ctx %>/css/common.css">
  <link rel="stylesheet" href="<%= ctx %>/css/header.css">
  <link rel="stylesheet" href="<%= ctx %>/css/footer.css">
  <link rel="stylesheet" href="<%= ctx %>/css/admin.css">
</head>
<body>
  <jsp:include page="/common/header.jsp" />

  <main class="container" style="padding-block: 56px;">
    <h1 class="section-title">상품 관리</h1>
    
        <div class="tablestyle">
        <%
  request.setCharacterEncoding("UTF-8");
 // String ctx = request.getContextPath();

  // 1. 삭제 요청(POST + action=delete) 처리
  if ("POST".equalsIgnoreCase(request.getMethod()) && "delete".equals(request.getParameter("action"))) {
    boolean ok = false;
    Connection delConn = null;
    try {
      int delId = Integer.parseInt(request.getParameter("productId"));
      delConn = DBUtil.getConnection();
      ProductDAO delDao = new ProductDAO();
      delDao.deleteById(delConn, delId);
      ok = true;
    } catch (Exception e) {
      e.printStackTrace();
    } finally {
      if (delConn != null) {
        try { delConn.close(); } catch (SQLException e) {}
      }
    }
    out.clear();
    response.setContentType("text/plain; charset=UTF-8");
    out.print(ok ? "ok" : "fail");
    return;
  }
         List<Product> list = null;
  Connection conn = null;
  try {
    conn = DBUtil.getConnection();
    ProductDAO dao = new ProductDAO();
    list = dao.selectList(conn);
  } catch (SQLException e) {
    e.printStackTrace();
  } finally {
    if (conn != null) {
      try { conn.close(); } catch (SQLException e) {}
    }
  }
  %>
           
           <table id="mylist">
                    <tr>
                      <th scope="col">아이디</th> 
                      <th scope="col">유형</th>
                      <th scope="col">카테고리</th>
                      <th scope="col">이름</th>
                      <th scope="col">가격</th>
                      <th scope="col">설명</th>
                      <th scope="col">케이크 이미지</th>
                      <th scope="col">제조일</th>
                      <th scope="col">수정</th>
                      <th scope="col">삭제</th>
                      
                    </tr>
                   <%
                      if (list != null) {
                        for (Product product : list) {
                    %>
                    <tr>
                      <td><%= product.getProductId() %></td>
                      <td><%= product.getType() %></td>
                      <td><%= product.getCategory() %></td>
                      <td><%= product.getName() %></td>
                      <td><%= product.getPrice() %></td>
                      <td><%= product.getDescription() %></td>
                      <td><% String rawImg = product.getImageUrl();
                             String imgPath = (rawImg != null) ? rawImg.trim() : "";
                             if (imgPath.startsWith("/")) {
                             imgPath = imgPath.substring(1);
                             }  %>
                          <% if (!imgPath.isEmpty()) { %>
                            <img src="<%= request.getContextPath() %>/<%= imgPath %>" alt="<%= product.getName() %>" width="50" height="70">
                          <% } else { %>
                                  없음
                          <% } %>  
                    </td>
                      <td><%= product.getCreatedAt() %></td>
                      <td><button onclick="location.href='<%= ctx %>/admin/product?action=updateForm&productId=<%= product.getProductId() %>'">수정</button></td>
                      <td><button type="button" onclick="cakeDelete( '<%=product.getProductId() %>', this)">삭제</button></td>
                    </tr>
               <%
                     }
                   }
               %>
             <tr>
              <td colspan="10"><button onclick="location.href='<%= ctx %>/admin/product?action=form'" id = "uploadProductbtn" >상품 추가</button></td>
             </tr>  
                  
            </table>          
               

    </div>
    
  </main>
    <script>
  function cakeDelete(productId, btn) {
    if (!confirm("정말 삭제하시겠습니까?")) return;   // 취소 → 여기서 끝

    fetch(location.pathname, {                          // 같은 페이지로 요청
      method: "POST",
      headers: { "Content-Type": "application/x-www-form-urlencoded; charset=UTF-8" },
      body: "action=delete&productId=" + encodeURIComponent(productId)
    })
    .then(res => res.text())
    .then(text => {
      if (text.trim() === "ok") {
        btn.closest("tr").remove();                     // 해당 행만 화면에서 제거
        alert("삭제되었습니다.");
      } else {
        alert("삭제에 실패했습니다.");
      }
    })
    .catch(() => alert("오류가 발생했습니다."));
  }
</script>
  <jsp:include page="/common/footer.jsp" />
</body>
</html>
