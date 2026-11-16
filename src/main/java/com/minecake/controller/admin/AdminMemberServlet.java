package com.minecake.controller.admin;

import java.io.IOException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;


/**
 * AdminMemberServlet — 역할 C
 * 할 일: 회원 목록, 회원별 주문 이력
 * 주소 예시: /admin/member?action=list
 */
@WebServlet("/admin/member")
public class AdminMemberServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        // TODO: action 값에 따라 DAO 호출 → req.setAttribute(...) → JSP로 forward
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        // TODO
    }
}
