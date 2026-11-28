package com.minecake.controller;

import java.io.IOException;
import java.net.URLEncoder;
import java.sql.SQLException;
import java.time.LocalDate;
import java.time.LocalTime;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

import com.minecake.dao.CartDAO;
import com.minecake.dao.OrderDAO;
import com.minecake.dto.CartItem;
import com.minecake.dto.Member;
import com.minecake.dto.Order;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

/**
 * OrderServlet — 역할 B (예지)
 *
 * 주소                                  하는 일
 * GET  /order?action=checkout           주문서 (장바구니 확인 + 픽업 일시 + 결제 수단)  → cart/checkout.jsp
 * POST /order  action=place             모의 결제 → 주문 저장 → 장바구니 비우기 → 완료 화면으로 이동
 * GET  /order?action=complete&id=12     주문 완료 (주문번호·픽업 일시)                → cart/complete.jsp
 * GET  /order?action=mypage             내 주문 내역 + 제작 상태                      → member/mypage.jsp
 *
 * 규칙
 * - 픽업 날짜: 내일 ~ 30일 뒤 / 픽업 시간: 11:00 ~ 19:00 (1시간 단위)
 * - 금액은 서버에서 장바구니로 다시 계산 (화면에서 보낸 금액은 안 씀)
 * - 주문하기를 두 번 눌러도 한 번만 저장 (주문서마다 1회용 번호 orderToken)
 */
@WebServlet("/order")
public class OrderServlet extends HttpServlet {

    public static final int OPEN_HOUR = 11;     // 첫 픽업 시간
    public static final int CLOSE_HOUR = 19;    // 마지막 픽업 시간
    public static final int MAX_DAYS = 30;      // 며칠 뒤까지 예약 가능

    /** 모의 결제 수단: 값 → 화면 이름 */
    public static final Map<String, String> PAY_METHODS = new LinkedHashMap<>();
    static {
        PAY_METHODS.put("CARD", "신용·체크카드");
        PAY_METHODS.put("KAKAO", "카카오페이");
        PAY_METHODS.put("BANK", "무통장 입금");
    }

    private final OrderDAO orderDAO = new OrderDAO();
    private final CartDAO cartDAO = new CartDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        String action = req.getParameter("action");
        if (action == null) action = "checkout";

        Member user = loginUser(req);
        if (user == null) {
            String back = "mypage".equals(action) ? "/order?action=mypage" : "/cart";
            redirectToLogin(req, resp, back);
            return;
        }

        try {
            switch (action) {
                case "complete": complete(req, resp, user); break;
                case "mypage":   mypage(req, resp, user);   break;
                default:         checkout(req, resp, user); break;
            }
        } catch (SQLException e) {
            throw new ServletException("주문 정보를 불러오지 못했어요.", e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        Member user = loginUser(req);
        if (user == null) {
            redirectToLogin(req, resp, "/cart");
            return;
        }
        if (!"place".equals(req.getParameter("action"))) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "알 수 없는 요청이에요.");
            return;
        }
        try {
            place(req, resp, user);
        } catch (SQLException e) {
            throw new ServletException("주문을 저장하지 못했어요. 잠시 후 다시 시도해 주세요.", e);
        }
    }

    // ---------------- ① 주문서 ----------------
    private void checkout(HttpServletRequest req, HttpServletResponse resp, Member user)
            throws ServletException, IOException, SQLException {
        List<CartItem> items = cartDAO.findByMember(user.getMemberId());
        if (items.isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/cart?msg=empty");
            return;
        }
        int total = 0;
        for (CartItem item : items) total += item.getLineTotal();

        // 두 번 주문 방지용 1회용 번호
        String token = UUID.randomUUID().toString();
        req.getSession().setAttribute("orderToken", token);

        LocalDate tomorrow = LocalDate.now().plusDays(1);
        req.setAttribute("cartItems", items);
        req.setAttribute("cartTotal", total);
        req.setAttribute("orderToken", token);
        req.setAttribute("minDate", tomorrow.toString());
        req.setAttribute("maxDate", LocalDate.now().plusDays(MAX_DAYS).toString());
        req.setAttribute("pickupTimes", pickupTimes());
        req.setAttribute("payMethods", PAY_METHODS);
        req.setAttribute("buyer", user);
        req.setAttribute("error", req.getParameter("error"));
        req.getRequestDispatcher("/cart/checkout.jsp").forward(req, resp);
    }

    // ---------------- ② 모의 결제 + 주문 저장 ----------------
    private void place(HttpServletRequest req, HttpServletResponse resp, Member user)
            throws IOException, SQLException {
        String ctx = req.getContextPath();
        HttpSession session = req.getSession();

        // 1회용 번호 확인 → 같은 주문서로 두 번 들어오면 두 번째는 무시
        String token = req.getParameter("orderToken");
        Object saved = session.getAttribute("orderToken");
        if (token == null || saved == null || !token.equals(saved)) {
            resp.sendRedirect(ctx + "/order?action=mypage&msg=already");
            return;
        }

        // 입력값 검사
        LocalDate date = parseDate(req.getParameter("pickupDate"));
        LocalTime time = parseTime(req.getParameter("pickupTime"));
        String pay = req.getParameter("payMethod");
        String error = null;
        if (date == null || date.isBefore(LocalDate.now().plusDays(1)) || date.isAfter(LocalDate.now().plusDays(MAX_DAYS))) {
            error = "date";
        } else if (time == null || time.getMinute() != 0 || time.getHour() < OPEN_HOUR || time.getHour() > CLOSE_HOUR) {
            error = "time";
        } else if (pay == null || !PAY_METHODS.containsKey(pay)) {
            error = "pay";
        } else if (req.getParameter("agree") == null) {
            error = "agree";
        }
        if (error != null) {
            resp.sendRedirect(ctx + "/order?action=checkout&error=" + error);
            return;
        }

        session.removeAttribute("orderToken");   // 이제부터 이 주문서는 다시 못 씀
        int orderId = orderDAO.placeOrder(user.getMemberId(), date, time);
        if (orderId < 0) {
            resp.sendRedirect(ctx + "/cart?msg=empty");
            return;
        }
        session.setAttribute("cartCount", 0);
        session.setAttribute("lastPay_" + orderId, PAY_METHODS.get(pay));   // 완료 화면에 보여줄 결제 수단
        resp.sendRedirect(ctx + "/order?action=complete&id=" + orderId);   // 새로고침해도 다시 결제되지 않게 redirect
    }

    // ---------------- ③ 주문 완료 ----------------
    private void complete(HttpServletRequest req, HttpServletResponse resp, Member user)
            throws ServletException, IOException, SQLException {
        int id = toInt(req.getParameter("id"));
        Order order = orderDAO.findById(id, user.getMemberId());
        if (order == null) {
            resp.sendRedirect(req.getContextPath() + "/order?action=mypage");
            return;
        }
        req.setAttribute("order", order);
        req.setAttribute("payLabel", req.getSession().getAttribute("lastPay_" + id));
        req.getRequestDispatcher("/cart/complete.jsp").forward(req, resp);
    }

    // ---------------- ④ 마이페이지 ----------------
    private void mypage(HttpServletRequest req, HttpServletResponse resp, Member user)
            throws ServletException, IOException, SQLException {
        req.setAttribute("orders", orderDAO.findByMember(user.getMemberId()));
        req.setAttribute("member", user);
        req.setAttribute("msg", req.getParameter("msg"));
        req.getRequestDispatcher("/member/mypage.jsp").forward(req, resp);
    }

    // ---------------- 도우미 ----------------
    private List<String> pickupTimes() {
        List<String> list = new ArrayList<>();
        for (int h = OPEN_HOUR; h <= CLOSE_HOUR; h++) list.add(String.format("%02d:00", h));
        return list;
    }

    private LocalDate parseDate(String s) {
        try { return LocalDate.parse(s.trim()); } catch (Exception e) { return null; }
    }

    private LocalTime parseTime(String s) {
        try { return LocalTime.parse(s.trim()); } catch (Exception e) { return null; }
    }

    private int toInt(String s) {
        try { return Integer.parseInt(s.trim()); } catch (Exception e) { return -1; }
    }

    private Member loginUser(HttpServletRequest req) {
        HttpSession session = req.getSession(false);
        return session == null ? null : (Member) session.getAttribute("loginUser");
    }

    private void redirectToLogin(HttpServletRequest req, HttpServletResponse resp, String back) throws IOException {
        String ctx = req.getContextPath();
        resp.sendRedirect(ctx + "/member/login.jsp?need=1&returnUrl=" + URLEncoder.encode(ctx + back, "UTF-8"));
    }
}
