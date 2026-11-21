package com.minecake.controller;

import java.io.IOException;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

import com.minecake.dao.CartDAO;
import com.minecake.dao.OptionDAO;
import com.minecake.dto.CartItem;
import com.minecake.dto.Member;
import com.minecake.dto.Product;
import com.minecake.dto.ProductOption;
import com.minecake.util.PriceCalculator;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

/**
 * CartServlet — 역할 B (2주차 · 장바구니 담기/조회, 3주차 · 금액 계산 · 커스텀 저장 · 수량 변경/삭제)
 *
 * 주소                          하는 일
 * GET  /cart                    내 장바구니 화면 (cart/cart.jsp)
 * POST /cart  action=add        담기
 * POST /cart  action=update     수량 변경
 * POST /cart  action=delete     삭제
 *
 * ★ 상품 상세·커스텀 화면(역할 A)에서 "장바구니 담기" 폼은 아래 이름으로 보내주세요 ★
 *   <form method="post" action="<%= ctx %>/cart">
 *     action    = add                  (hidden)
 *     productId = 상품 번호             (hidden)
 *     optionId  = 선택한 옵션 번호       (종류별로 하나씩: 크기·맛·크림 색·장식 → 같은 이름으로 여러 개)
 *     lettering = 레터링 문구 (최대 20자, 10자 넘으면 +1,000원)
 *     request   = 요청사항 (선택)
 *     quantity  = 수량 (1~10, 없으면 1)
 *   가격은 보내지 않아도 됨 → 여기서 DB 가격으로 다시 계산함
 */
@WebServlet("/cart")
public class CartServlet extends HttpServlet {

    private static final int MAX_QUANTITY = 10;

    private final CartDAO cartDAO = new CartDAO();
    private final OptionDAO optionDAO = new OptionDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        Member user = loginUser(req);
        if (user == null) {
            redirectToLogin(req, resp);
            return;
        }
        try {
            List<CartItem> items = cartDAO.findByMember(user.getMemberId());
            int total = 0;
            for (CartItem item : items) total += item.getLineTotal();

            req.getSession().setAttribute("cartCount", items.size());
            req.setAttribute("cartItems", items);
            req.setAttribute("cartTotal", total);
            req.getRequestDispatcher("/cart/cart.jsp").forward(req, resp);
        } catch (SQLException e) {
            throw new ServletException("장바구니를 불러오지 못했어요.", e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        Member user = loginUser(req);
        if (user == null) {
            redirectToLogin(req, resp);
            return;
        }

        String action = req.getParameter("action");
        try {
            String message;
            if ("add".equals(action)) {
                message = add(req, user);
            } else if ("update".equals(action)) {
                int quantity = clamp(toInt(req.getParameter("quantity"), 1));
                cartDAO.updateQuantity(toInt(req.getParameter("cartId"), -1), user.getMemberId(), quantity);
                message = null;
            } else if ("delete".equals(action)) {
                cartDAO.delete(toInt(req.getParameter("cartId"), -1), user.getMemberId());
                message = "deleted";
            } else {
                resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "알 수 없는 요청이에요.");
                return;
            }

            req.getSession().setAttribute("cartCount", cartDAO.countByMember(user.getMemberId()));

            // 처리 후에는 장바구니 화면으로 이동 (새로고침해도 두 번 담기지 않게 redirect)
            String url = req.getContextPath() + "/cart";
            if (message != null) url += "?msg=" + message;
            resp.sendRedirect(url);
        } catch (SQLException e) {
            throw new ServletException("장바구니 처리 중 오류가 났어요.", e);
        }
    }

    // ---------------- 담기 (3주차: 옵션 금액 계산 + 커스텀 내용 저장) ----------------
    private String add(HttpServletRequest req, Member user) throws SQLException {
        Product product = cartDAO.findProductForCart(toInt(req.getParameter("productId"), -1));
        if (product == null) return "noProduct";

        // 1) 옵션: 화면에서 온 번호로 DB에서 실제 옵션을 다시 꺼냄 (종류별로 하나만 인정)
        List<ProductOption> options = new ArrayList<>();
        if ("CAKE".equals(product.getType())) {
            List<Integer> ids = new ArrayList<>();
            String[] raw = req.getParameterValues("optionId");
            if (raw != null) {
                for (String r : raw) {
                    int id = toInt(r, -1);
                    if (id > 0) ids.add(id);
                }
            }
            Set<String> usedTypes = new HashSet<>();
            for (ProductOption o : optionDAO.findByIds(ids)) {
                if (usedTypes.add(o.getOptionType())) options.add(o);
            }
        }

        // 2) 레터링: 앞뒤 공백 제거, 최대 20자
        String lettering = trim(req.getParameter("lettering"));
        if (lettering.length() > PriceCalculator.MAX_LETTERING_LENGTH) {
            lettering = lettering.substring(0, PriceCalculator.MAX_LETTERING_LENGTH);
        }
        String request = trim(req.getParameter("request"));
        if (request.length() > 200) request = request.substring(0, 200);

        // 3) 가격 계산 (서버에서)
        int unitPrice = PriceCalculator.unitPrice(product.getPrice(), options, lettering);

        // 4) 저장 — 옵션은 "1호 (3~4인) / 초코 / 파스텔 핑크" 처럼 글자로 묶어서 저장
        //    → 나중에 관리자가 옵션 이름을 바꿔도, 주문 당시 고른 내용이 그대로 남음
        StringBuilder summary = new StringBuilder();
        for (ProductOption o : options) {
            if (summary.length() > 0) summary.append(" / ");
            summary.append(o.getName());
        }

        CartItem item = new CartItem();
        item.setMemberId(user.getMemberId());
        item.setProductId(product.getProductId());
        item.setOptions(summary.length() == 0 ? null : summary.toString());
        item.setLettering(lettering.isEmpty() ? null : lettering);
        item.setRequest(request.isEmpty() ? null : request);
        item.setQuantity(clamp(toInt(req.getParameter("quantity"), 1)));
        item.setPrice(unitPrice);
        cartDAO.add(item);
        return "added";
    }

    // ---------------- 도우미 ----------------
    private Member loginUser(HttpServletRequest req) {
        HttpSession session = req.getSession(false);
        return session == null ? null : (Member) session.getAttribute("loginUser");
    }

    private void redirectToLogin(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        String ctx = req.getContextPath();
        resp.sendRedirect(ctx + "/member/login.jsp?need=1&returnUrl="
                + java.net.URLEncoder.encode(ctx + "/cart", "UTF-8"));
    }

    private int clamp(int quantity) {
        return Math.max(1, Math.min(MAX_QUANTITY, quantity));
    }

    private int toInt(String s, int fallback) {
        try {
            return Integer.parseInt(s.trim());
        } catch (Exception e) {
            return fallback;
        }
    }

    private String trim(String s) {
        return s == null ? "" : s.trim();
    }
}
