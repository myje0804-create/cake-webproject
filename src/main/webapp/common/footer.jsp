<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%--
  footer.jsp — 모든 페이지 맨 아래 공통 영역
  스케치 FOOTER: 사업자 정보 / 이용약관 / 고객센터 / 개인정보 처리방침
  ※ 사업자 정보는 수업 과제용 예시 값
--%>
<% String ctx = request.getContextPath(); %>
<footer class="site-footer">
  <div class="container footer-inner">

    <div class="footer-brand">
      <div class="footer-logo">Mine Cake</div>
      <p>나만의 디자인으로 만드는 주문 제작 케이크</p>
    </div>

    <div class="footer-col">
      <h4>고객센터</h4>
      <p class="footer-phone">02-000-0000</p>
      <p>평일 10:00 ~ 19:00 (점심 12:30 ~ 13:30)<br>주말·공휴일 휴무</p>
      <a href="<%= ctx %>/support/inquiry.jsp" class="footer-link">1:1 문의하기 &rarr;</a>
    </div>

    <div class="footer-col">
      <h4>사업자 정보</h4>
      <p>상호 Mine Cake · 대표 문예지<br>
         사업자등록번호 000-00-00000 (과제용 예시)<br>
         주소 서울특별시 ○○구 ○○로 00</p>
    </div>
  </div>

  <div class="container footer-bottom">
    <nav class="footer-links" aria-label="약관">
      <a href="<%= ctx %>/policy/terms.jsp">이용약관</a>
      <a href="<%= ctx %>/policy/privacy.jsp"><strong>개인정보 처리방침</strong></a>
      <a href="<%= ctx %>/support/notice.jsp">공지사항</a>
    </nav>
    <p class="copyright">&copy; 2026 Mine Cake. 웹프로그래밍응용 텀프로젝트</p>
  </div>
</footer>
