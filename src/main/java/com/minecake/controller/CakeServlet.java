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

/**
 * CakeServlet — 상품 목록·상세 (예지)
 *
 * 주소                                   하는 일
 * GET /cake                              케이크 목록 (cake/list.jsp)
 * GET /cake?category=CHARACTER&sort=name  카테고리 + 정렬
 * GET /cake?type=ADDON                   추가 상품 목록 (숫자초·토퍼·칼)
 * GET /cake?id=3                         상품 상세 (cake/detail.jsp)
 *                                        + 사진 여러 장, 원재료·영양성분, 다른 고객 커스텀 사진
 *
 * sort 값: (없음)=추천순, name=이름순, price_asc=낮은 가격순, price_desc=높은 가격순, review=리뷰 많은 순
 */
@WebServlet("/cake")
public class CakeServlet extends HttpServlet {

    /** 카테고리: DB 값 → 화면에 보일 이름 (순서대로 탭이 그려짐) */
    public static final Map<String, String> CATEGORIES = new LinkedHashMap<>();
    static {
        CATEGORIES.put("LETTERING", "레터링");
        CATEGORIES.put("CHARACTER", "캐릭터");
        CATEGORIES.put("LUNCHBOX", "도시락");
        CATEGORIES.put("FLOWER", "플라워");
        CATEGORIES.put("SEASON", "시즌");
    }

    /** 정렬: 값 → 화면에 보일 이름 */
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

        // 정해진 값만 받기 (이상한 값이 오면 '전체' / '추천순'으로)
        String category = req.getParameter("category");
        if (!"CAKE".equals(type) || category == null || !CATEGORIES.containsKey(category)) category = "";
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
            // 숫자가 아니면 없는 상품으로 처리
        }
        if (product == null) {
            resp.sendError(HttpServletResponse.SC_NOT_FOUND, "없는 상품이에요.");
            return;
        }
        int productId = product.getProductId();
        req.setAttribute("product", product);
        req.setAttribute("images", productDAO.findImages(productId));          // 대표·옆모습·위에서 사진
        req.setAttribute("info", productDAO.findInfo(productId));              // 원재료·영양성분 (없으면 null)
        req.setAttribute("showcase", reviewDAO.findCustomShowcase(productId, 8)); // 다른 고객 커스텀 사진
        req.getRequestDispatcher("/cake/detail.jsp").forward(req, resp);
    }
}
