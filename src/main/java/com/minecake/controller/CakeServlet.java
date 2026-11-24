package com.minecake.controller;

import java.io.IOException;
import java.sql.SQLException;
import java.util.LinkedHashMap;
import java.util.Map;

import com.minecake.dao.ProductDAO;
import com.minecake.dao.ReviewDAO;
import com.minecake.dto.Product;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/cake")
public class CakeServlet extends HttpServlet {

    /** 1차 메인 카테고리: DB 값 -> 화면에 보일 이름 */
    public static final Map<String, String> CATEGORIES = new LinkedHashMap<>();
    static {
        CATEGORIES.put("COUPLE", "커플/기념일");
        CATEGORIES.put("FRIEND", "친구/우정");
        CATEGORIES.put("PARENTS", "부모님/효도");
        CATEGORIES.put("CAREER", "취업/퇴사/입학/졸업");
        CATEGORIES.put("BIRTHDAY", "생일");
        CATEGORIES.put("DESIGN", "디자인케이크");
        CATEGORIES.put("FLOWER", "플라워/앙금");
        CATEGORIES.put("BITE", "한입케이크");
        CATEGORIES.put("SEASON", "시즌");
    }

    /** 2차 시즌 세부 카테고리 (SEASON 선택 시 하단에 노출) */
    public static final Map<String, String> SEASON_CATEGORIES = new LinkedHashMap<>();
    static {
        SEASON_CATEGORIES.put("SEASON_CHRISTMAS", "크리스마스");
        SEASON_CATEGORIES.put("SEASON_TEACHER", "스승의날");
        SEASON_CATEGORIES.put("SEASON_VALENTINE", "발렌타인데이 / 화이트데이");
        SEASON_CATEGORIES.put("SEASON_CHILDRENS", "어린이날");
        SEASON_CATEGORIES.put("SEASON_HOLIDAY", "명절 (설날 / 추석)");
        SEASON_CATEGORIES.put("SEASON_NEWYEAR", "연말 / 새해 (해피뉴이어)");
    }

    /** 전체 카테고리 이름 조회용 헬퍼 */
    public static String getCategoryLabel(String code) {
        if (code == null) return null;
        if (CATEGORIES.containsKey(code)) return CATEGORIES.get(code);
        if (SEASON_CATEGORIES.containsKey(code)) return "시즌 · " + SEASON_CATEGORIES.get(code);
        return null;
    }

    /** 정렬: 값 -> 화면에 보일 이름 */
    public static final Map<String, String> SORTS = new LinkedHashMap<>();
    static {
        SORTS.put("", "추천순");
        SORTS.put("name", "이름순");
        SORTS.put("price_asc", "낮은 가격순");
        SORTS.put("price_desc", "높은 가격순");
        SORTS.put("review", "리뷰 많은 순");
    }

    private final ProductDAO productDAO = new ProductDAO();
    private final ReviewDAO reviewDAO = new ReviewDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        try {
            String id = req.getParameter("id");
            if (id != null) {
                showDetail(req, resp, id);
            } else {
                showList(req, resp);
            }
        } catch (SQLException e) {
            throw new ServletException("상품을 불러오지 못했어요. MySQL이 켜져 있는지 확인하세요.", e);
        }
    }

    // ---------------- 목록 ----------------
    private void showList(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException, SQLException {
        String type = "ADDON".equals(req.getParameter("type")) ? "ADDON" : "CAKE";

        String category = req.getParameter("category");
        boolean validCategory = category != null && (CATEGORIES.containsKey(category) || SEASON_CATEGORIES.containsKey(category));
        if (!"CAKE".equals(type) || !validCategory) category = "";

        String sort = req.getParameter("sort");
        if (sort == null || !SORTS.containsKey(sort)) sort = "";

        req.setAttribute("type", type);
        req.setAttribute("category", category);
        req.setAttribute("sort", sort);
        req.setAttribute("products", productDAO.findList(type, category, sort));
        req.getRequestDispatcher("/cake/list.jsp").forward(req, resp);
    }

    // ---------------- 상세 ----------------
    private void showDetail(HttpServletRequest req, HttpServletResponse resp, String idText)
            throws ServletException, IOException, SQLException {
        Product product = null;
        try {
            product = productDAO.findById(Integer.parseInt(idText.trim()));
        } catch (NumberFormatException ignore) {
        }
        if (product == null) {
            resp.sendError(HttpServletResponse.SC_NOT_FOUND, "없는 상품이에요.");
            return;
        }
        int productId = product.getProductId();
        req.setAttribute("product", product);
        req.setAttribute("images", productDAO.findImages(productId));
        req.setAttribute("info", productDAO.findInfo(productId));
        req.setAttribute("showcase", reviewDAO.findCustomShowcase(productId, 8));
        req.getRequestDispatcher("/cake/detail.jsp").forward(req, resp);
    }
}