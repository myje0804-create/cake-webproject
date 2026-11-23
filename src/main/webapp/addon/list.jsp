<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%--
  addon/list.jsp — ④ 추가 상품
  상품 목록 화면(cake/list.jsp)을 같이 쓰므로 /cake?type=ADDON 으로 보냄
--%>
<% response.sendRedirect(request.getContextPath() + "/cake?type=ADDON"); %>
