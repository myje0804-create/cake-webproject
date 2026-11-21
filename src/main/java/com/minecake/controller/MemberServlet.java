package com.minecake.controller;

import java.io.IOException;
import java.sql.SQLException;

import com.minecake.dao.CartDAO;
import com.minecake.dao.MemberDAO;
import com.minecake.dto.Member;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

/**
 * MemberServlet — 역할 B (2주차 · 회원가입 · 로그인 · 로그아웃)
 *
 * 주소                         하는 일
 * POST /member  action=join    회원가입 → 성공하면 로그인 화면으로
 * POST /member  action=login   로그인 → 세션에 loginUser 저장
 * GET  /member?action=logout   로그아웃 → 메인으로
 *
 * 로그인하면 세션에 담기는 것 (다른 팀원도 이 이름으로 꺼내 쓰면 됨)
 *   loginUser  : Member 객체 (role이 "ADMIN"이면 관리자)
 *   cartCount  : 장바구니 항목 수 (헤더 아이콘 숫자)
 */
@WebServlet("/member")
public class MemberServlet extends HttpServlet {

    private final MemberDAO memberDAO = new MemberDAO();
    private final CartDAO cartDAO = new CartDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String action = req.getParameter("action");

        if ("logout".equals(action)) {
            HttpSession session = req.getSession(false);
            if (session != null) session.invalidate();   // 세션 통째로 비우기
            resp.sendRedirect(req.getContextPath() + "/index.jsp");
            return;
        }
        // 그 외 GET 요청은 로그인 화면으로
        resp.sendRedirect(req.getContextPath() + "/member/login.jsp");
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        String action = req.getParameter("action");

        try {
            if ("join".equals(action)) {
                join(req, resp);
            } else if ("login".equals(action)) {
                login(req, resp);
            } else {
                resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "알 수 없는 요청이에요.");
            }
        } catch (SQLException e) {
            throw new ServletException("DB 처리 중 오류가 났어요. MySQL이 켜져 있는지, DBUtil 비밀번호가 맞는지 확인하세요.", e);
        }
    }

    // ---------------- 회원가입 ----------------
    private void join(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException, SQLException {
        String loginId = trim(req.getParameter("loginId"));
        String password = req.getParameter("password");
        String passwordConfirm = req.getParameter("passwordConfirm");
        String name = trim(req.getParameter("name"));
        String phone = trim(req.getParameter("phone"));
        String email = trim(req.getParameter("email"));

        // 1) 입력값 검사 — 화면(HTML)에서도 검사하지만, 서버에서 한 번 더 확인해야 안전함
        String error = null;
        if (!loginId.matches("[a-zA-Z0-9]{4,20}")) {
            error = "아이디는 영문과 숫자 4~20자로 입력해 주세요.";
        } else if (password == null || password.length() < 6) {
            error = "비밀번호는 6자 이상으로 입력해 주세요.";
        } else if (!password.equals(passwordConfirm)) {
            error = "비밀번호 확인이 일치하지 않아요.";
        } else if (name.isEmpty()) {
            error = "이름을 입력해 주세요.";
        } else if (!phone.isEmpty() && !phone.matches("[0-9\\-]{9,13}")) {
            error = "전화번호는 숫자와 - 만 입력해 주세요. (예: 010-1234-5678)";
        } else if (memberDAO.existsLoginId(loginId)) {
            error = "이미 사용 중인 아이디예요.";
        }

        if (error != null) {
            // 실패: 입력했던 값을 그대로 돌려줘서 다시 안 쳐도 되게 함 (비밀번호는 제외)
            req.setAttribute("error", error);
            req.getRequestDispatcher("/member/join.jsp").forward(req, resp);
            return;
        }

        // 2) 저장
        Member m = new Member();
        m.setLoginId(loginId);
        m.setName(name);
        m.setPhone(phone.isEmpty() ? null : phone);
        m.setEmail(email.isEmpty() ? null : email);
        memberDAO.insert(m, password);

        // 3) 성공 → 로그인 화면으로 (새로고침해도 다시 가입되지 않게 redirect)
        resp.sendRedirect(req.getContextPath() + "/member/login.jsp?joined=1");
    }

    // ---------------- 로그인 ----------------
    private void login(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException, SQLException {
        String loginId = trim(req.getParameter("loginId"));
        String password = req.getParameter("password");
        String returnUrl = req.getParameter("returnUrl");

        Member member = (password == null) ? null : memberDAO.login(loginId, password);
        if (member == null) {
            req.setAttribute("error", "아이디 또는 비밀번호가 맞지 않아요.");
            req.getRequestDispatcher("/member/login.jsp").forward(req, resp);
            return;
        }

        // 로그인 성공: 이전 세션을 버리고 새 세션 시작 (보안)
        HttpSession old = req.getSession(false);
        if (old != null) old.invalidate();
        HttpSession session = req.getSession(true);
        session.setAttribute("loginUser", member);
        session.setAttribute("cartCount", cartDAO.countByMember(member.getMemberId()));

        resp.sendRedirect(safeReturnUrl(req, returnUrl));
    }

    /** 로그인 후 돌아갈 주소: 우리 사이트 안의 주소만 허용 (다른 사이트로 튕기는 것 방지) */
    private String safeReturnUrl(HttpServletRequest req, String returnUrl) {
        String ctx = req.getContextPath();
        if (returnUrl != null && returnUrl.startsWith(ctx + "/") && !returnUrl.startsWith("//")) {
            return returnUrl;
        }
        return ctx + "/index.jsp";
    }

    private String trim(String s) {
        return s == null ? "" : s.trim();
    }
}
