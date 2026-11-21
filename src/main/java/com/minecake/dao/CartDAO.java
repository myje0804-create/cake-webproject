package com.minecake.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import com.minecake.dto.CartItem;
import com.minecake.dto.Product;
import com.minecake.util.DBUtil;

/**
 * CartDAO — 역할 B
 * 장바구니 담기 · 목록 · 수량 변경 · 삭제
 * 수정/삭제는 항상 "member_id = 로그인한 회원"을 같이 확인해서 남의 장바구니를 못 건드리게 함
 */
public class CartDAO {

    /** 담을 상품의 기본 정보(이름·기본 가격·종류). 없는 상품이면 null */
    public Product findProductForCart(int productId) throws SQLException {
        String sql = "SELECT product_id, type, name, price FROM product WHERE product_id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, productId);
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) return null;
                Product p = new Product();
                p.setProductId(rs.getInt("product_id"));
                p.setType(rs.getString("type"));
                p.setName(rs.getString("name"));
                p.setPrice(rs.getInt("price"));
                return p;
            }
        }
    }

    /** 장바구니에 담기 (가격은 CartServlet에서 계산해서 넘겨줌) */
    public int add(CartItem item) throws SQLException {
        String sql = "INSERT INTO cart (member_id, product_id, options, lettering, request, quantity, price) "
                   + "VALUES (?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, item.getMemberId());
            ps.setInt(2, item.getProductId());
            ps.setString(3, item.getOptions());
            ps.setString(4, item.getLettering());
            ps.setString(5, item.getRequest());
            ps.setInt(6, item.getQuantity());
            ps.setInt(7, item.getPrice());
            return ps.executeUpdate();
        }
    }

    /** 내 장바구니 목록 (상품 이름·사진은 product 테이블에서 같이 가져옴) */
    public List<CartItem> findByMember(int memberId) throws SQLException {
        String sql = "SELECT c.cart_id, c.member_id, c.product_id, c.options, c.lettering, c.request, "
                   + "       c.quantity, c.price, p.name AS product_name, p.image_url "
                   + "FROM cart c JOIN product p ON c.product_id = p.product_id "
                   + "WHERE c.member_id = ? ORDER BY c.cart_id DESC";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, memberId);
            try (ResultSet rs = ps.executeQuery()) {
                List<CartItem> list = new ArrayList<>();
                while (rs.next()) {
                    CartItem c = new CartItem();
                    c.setCartId(rs.getInt("cart_id"));
                    c.setMemberId(rs.getInt("member_id"));
                    c.setProductId(rs.getInt("product_id"));
                    c.setOptions(rs.getString("options"));
                    c.setLettering(rs.getString("lettering"));
                    c.setRequest(rs.getString("request"));
                    c.setQuantity(rs.getInt("quantity"));
                    c.setPrice(rs.getInt("price"));
                    c.setProductName(rs.getString("product_name"));
                    c.setImageUrl(rs.getString("image_url"));
                    list.add(c);
                }
                return list;
            }
        }
    }

    /** 수량 변경 (내 장바구니 항목만) */
    public int updateQuantity(int cartId, int memberId, int quantity) throws SQLException {
        String sql = "UPDATE cart SET quantity = ? WHERE cart_id = ? AND member_id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, quantity);
            ps.setInt(2, cartId);
            ps.setInt(3, memberId);
            return ps.executeUpdate();
        }
    }

    /** 삭제 (내 장바구니 항목만) */
    public int delete(int cartId, int memberId) throws SQLException {
        String sql = "DELETE FROM cart WHERE cart_id = ? AND member_id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, cartId);
            ps.setInt(2, memberId);
            return ps.executeUpdate();
        }
    }

    /** 헤더 장바구니 아이콘에 표시할 항목 개수 */
    public int countByMember(int memberId) throws SQLException {
        String sql = "SELECT COUNT(*) FROM cart WHERE member_id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, memberId);
            try (ResultSet rs = ps.executeQuery()) {
                rs.next();
                return rs.getInt(1);
            }
        }
    }
}
