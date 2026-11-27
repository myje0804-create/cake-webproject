package com.minecake.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import java.sql.Statement;
import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.sql.*;
import java.util.*;

import com.minecake.dto.Product;
import com.minecake.dto.ProductImage;
import com.minecake.dto.ProductInfo;
import com.minecake.util.DBUtil;

public class ProductDAO {

    /** 정렬 기준 -> SQL ORDER BY */
    private String orderBy(String sort) {
        if (sort == null) sort = "";
        switch (sort) {
            case "name":       return "p.name ASC";
            case "price_asc":  return "p.price ASC, p.name ASC";
            case "price_desc": return "p.price DESC, p.name ASC";
            case "review":     return "review_count DESC, p.name ASC";
            default:           return "p.is_best DESC, p.product_id DESC";
        }
    }

    /** 상품 목록 (SEASON 선택 시 SEASON 및 SEASON_* 전체 조회) */
    public List<Product> findList(String type, String category, String sort) throws SQLException {
        StringBuilder sql = new StringBuilder(
            "SELECT p.*, IFNULL(r.cnt, 0) AS review_count "
          + "FROM product p "
          + "LEFT JOIN (SELECT product_id, COUNT(*) AS cnt FROM review WHERE is_hidden = FALSE GROUP BY product_id) r "
          + "  ON p.product_id = r.product_id "
          + "WHERE p.type = ? ");

        boolean isSeasonAll = "SEASON".equals(category);
        boolean byCategory = category != null && !category.isEmpty() && !isSeasonAll;

        if (isSeasonAll) {
            sql.append("AND (p.category = 'SEASON' OR p.category LIKE 'SEASON\\_%') ");
        } else if (byCategory) {
            sql.append("AND p.category = ? ");
        }
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

    /** 상품 사진 여러 장 (대표 -> 옆모습 -> 위에서 순서) */
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

    public void insert(Connection conn, Product product) throws SQLException { //케이크 데이터 삽입
     String sql = "insert into Product (type, category, name, price, description, image_url, is_best) "
                   + "values (?,?,?,?,?,?,?)";

        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, product.getType());
            pstmt.setString(2, product.getCategory());
            pstmt.setString(3, product.getName());
            pstmt.setInt(4, product.getPrice());
            pstmt.setString(5, product.getDescription());
            pstmt.setString(6, product.getImageUrl());  
            pstmt.setBoolean(7, product.getBest());
            //pstmt.setTimestamp(8, Timestamp.valueOf(product.getCreatedAt()));
            pstmt.executeUpdate();
        }
    }
	
    public Product selectById(Connection conn, int productId) throws SQLException {
        Product product = null;
        String sql = "select * from Product where product_id = ?";

        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, productId);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    product = new Product();
                    product.setProductId(rs.getInt(1));
                product.setType(rs.getString(2));
                product.setCategory(rs.getString(3));
                product.setName(rs.getString(4));
                product.setPrice(rs.getInt(5));
                product.setDescription(rs.getString(6));
                product.setImageUrl(rs.getString(7));
                product.setBest(rs.getBoolean(8));
                Timestamp ts = rs.getTimestamp(9);
                if (ts != null) product.setCreatedAt(ts.toLocalDateTime());
                }
            }
        }
        return product;
    }
	
	
	
	
    public void update(Connection conn, Product product) throws SQLException {  //케이크 정보 업데이트
        String sql = "update Product set type=?, category=?, name=?, price=?, "
                + " description=?, image_url=?, is_best=?, created_at=? where product_id =?";

        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, product.getType());
            pstmt.setString(2, product.getCategory());
            pstmt.setString(3, product.getName());
            pstmt.setInt(4, product.getPrice());
            pstmt.setString(5, product.getDescription());
            pstmt.setString(6, product.getImageUrl());  
            pstmt.setBoolean(7, product.getBest());
            LocalDateTime createdAt = (product.getCreatedAt() != null)
                    ? product.getCreatedAt()
                    : LocalDateTime.now();
            pstmt.setTimestamp(8, Timestamp.valueOf(createdAt));
           
            pstmt.setInt(9, product.getProductId());
            pstmt.executeUpdate();
        }
    }

	
	public void deleteById(Connection conn, int productId) throws SQLException { //케이크 정보 삭제
    String sql = "delete from Product where product_id = ?";

        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, productId);
            pstmt.executeUpdate();
        }
    }
	
	public List<Product> selectList(Connection conn) throws SQLException {  //케이크 관리 리스트 출력용 
        List<Product> productList = new ArrayList<>();
        String sql = "select * from product";

        try (PreparedStatement pstmt = conn.prepareStatement(sql);
            ResultSet rs = pstmt.executeQuery()) {

            while (rs.next()) {
                Product product = new Product();
                product.setProductId(rs.getInt(1));
                product.setType(rs.getString(2));
                product.setCategory(rs.getString(3));
                product.setName(rs.getString(4));
                product.setPrice(rs.getInt(5));
                product.setDescription(rs.getString(6));
                product.setImageUrl(rs.getString(7));
                product.setBest(rs.getBoolean(8));
                Timestamp ts = rs.getTimestamp(9);
                if (ts != null) product.setCreatedAt(ts.toLocalDateTime());
                productList.add(product);
            }
        }
        return productList;
    }
}