package com.minecake.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import com.minecake.dto.Product;
import com.minecake.dto.ProductImage;
import com.minecake.dto.ProductInfo;
import com.minecake.util.DBUtil;

/**
 * ProductDAO — 상품 조회 (예지: 목록·카테고리·정렬·상세)
 * 관리자 상품 등록·수정·삭제(선우)는 이 파일 아래쪽에 메서드를 추가하면 됨
 */
public class ProductDAO {

    /** 정렬 기준 → SQL ORDER BY (화면에서 온 값을 그대로 SQL에 넣지 않고, 정해진 것만 고름) */
    private String orderBy(String sort) {
        if (sort == null) sort = "";
        switch (sort) {
            case "name":       return "p.name ASC";
            case "price_asc":  return "p.price ASC, p.name ASC";
            case "price_desc": return "p.price DESC, p.name ASC";
            case "review":     return "review_count DESC, p.name ASC";
            default:           return "p.is_best DESC, p.product_id DESC";   // 추천순: Best 먼저, 최신 순
        }
    }

    /**
     * 상품 목록
     * @param type     CAKE(케이크) / ADDON(추가 상품)
     * @param category LETTERING, CHARACTER ... (null이나 빈 값이면 전체)
     * @param sort     name / price_asc / price_desc / review / 그 외(추천순)
     */
    public List<Product> findList(String type, String category, String sort) throws SQLException {
        StringBuilder sql = new StringBuilder(
            "SELECT p.*, IFNULL(r.cnt, 0) AS review_count "
          + "FROM product p "
          + "LEFT JOIN (SELECT product_id, COUNT(*) AS cnt FROM review WHERE is_hidden = FALSE GROUP BY product_id) r "
          + "  ON p.product_id = r.product_id "
          + "WHERE p.type = ? ");
        boolean byCategory = category != null && !category.isEmpty();
        if (byCategory) sql.append("AND p.category = ? ");
        sql.append("ORDER BY ").append(orderBy(sort));

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            ps.setString(1, type);
            if (byCategory) ps.setString(2, category);
            try (ResultSet rs = ps.executeQuery()) {
                List<Product> list = new ArrayList<>();
                while (rs.next()) list.add(map(rs));
                return list;
            }
        }
    }

    /** 상품 1개 (상세 화면). 없으면 null */
    public Product findById(int productId) throws SQLException {
        String sql = "SELECT p.*, "
                   + "  (SELECT COUNT(*) FROM review r WHERE r.product_id = p.product_id AND r.is_hidden = FALSE) AS review_count "
                   + "FROM product p WHERE p.product_id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, productId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? map(rs) : null;
            }
        }
    }

    /** 상품 사진 여러 장 (대표 → 옆모습 → 위에서 순서) */
    public List<ProductImage> findImages(int productId) throws SQLException {
        String sql = "SELECT image_id, product_id, view_type, image_url FROM product_image "
                   + "WHERE product_id = ? ORDER BY sort_order, image_id";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, productId);
            try (ResultSet rs = ps.executeQuery()) {
                List<ProductImage> list = new ArrayList<>();
                while (rs.next()) {
                    ProductImage img = new ProductImage();
                    img.setImageId(rs.getInt("image_id"));
                    img.setProductId(rs.getInt("product_id"));
                    img.setViewType(rs.getString("view_type"));
                    img.setImageUrl(rs.getString("image_url"));
                    list.add(img);
                }
                return list;
            }
        }
    }

    /** 원재료·원산지·영양성분·알레르기·보관 정보. 등록 안 된 상품이면 null */
    public ProductInfo findInfo(int productId) throws SQLException {
        String sql = "SELECT * FROM product_info WHERE product_id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, productId);
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) return null;
                ProductInfo info = new ProductInfo();
                info.setProductId(rs.getInt("product_id"));
                info.setIngredients(rs.getString("ingredients"));
                info.setAllergens(rs.getString("allergens"));
                info.setServingBasis(rs.getString("serving_basis"));
                info.setKcal((Integer) rs.getObject("kcal", Integer.class));
                info.setSugarG((Double) rs.getObject("sugar_g", Double.class));
                info.setProteinG((Double) rs.getObject("protein_g", Double.class));
                info.setFatG((Double) rs.getObject("fat_g", Double.class));
                info.setSatFatG((Double) rs.getObject("sat_fat_g", Double.class));
                info.setSodiumMg((Integer) rs.getObject("sodium_mg", Integer.class));
                info.setStorage(rs.getString("storage"));
                return info;
            }
        }
    }

    private Product map(ResultSet rs) throws SQLException {
        Product p = new Product();
        p.setProductId(rs.getInt("product_id"));
        p.setType(rs.getString("type"));
        p.setCategory(rs.getString("category"));
        p.setName(rs.getString("name"));
        p.setPrice(rs.getInt("price"));
        p.setDescription(rs.getString("description"));
        p.setImageUrl(rs.getString("image_url"));
        p.setBest(rs.getBoolean("is_best"));
        p.setReviewCount(rs.getInt("review_count"));
        return p;
    }

    // ---------------- 아래는 관리자 기능(선우) 자리 ----------------
    // TODO: insert(Product), update(Product), delete(int productId), setBest(int productId, boolean best)
}
