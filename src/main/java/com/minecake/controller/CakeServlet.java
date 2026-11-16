package com.minecake.controller;

import java.io.IOException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;


/**
 * CakeServlet — 역할 A
 * 할 일: 목록·정렬·상세
 * 주소 예시: /cake?action=list
 */
@WebServlet("/cake")
public class CakeServlet extends HttpServlet {

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
