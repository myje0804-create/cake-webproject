package com.minecake.dao;

import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import com.minecake.dto.CustomShowcase;
import com.minecake.util.DBUtil;

/**
 * ReviewDAO — 역할 B (예지)
 * 지금 있는 것: 상품 상세의 "다른 고객님들의 커스텀" 사진 모음
 * TODO: 후기 작성, 후기 목록, 메인 화면 최근 후기
 */
public class ReviewDAO {

    /**
     * 이 상품을 주문한 고객들이 올린 사진 후기 + 그 주문의 옵션·레터링
     * (숨김 처리된 후기, 사진 없는 후기는 제외)
     */
    public List<CustomShowcase> findCustomShowcase(int productId, int limit) throws SQLException {
        String sql = "SELECT r.review_id, r.image_url, r.rating, r.content, m.name AS writer_name, "
                   + "       oi.options, oi.lettering, o.pickup_date "
                   + "FROM review r "
                   + "JOIN member m ON r.member_id = m.member_id "
                   + "JOIN orders o ON r.order_id = o.order_id "
                   + "LEFT JOIN order_item oi ON oi.order_id = r.order_id AND oi.product_id = r.product_id "
                   + "WHERE r.product_id = ? AND r.is_hidden = FALSE AND r.image_url IS NOT NULL "
                   + "ORDER BY r.created_at DESC, r.review_id DESC "
                   + "LIMIT ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, productId);
            ps.setInt(2, limit);
            try (ResultSet rs = ps.executeQuery()) {
                List<CustomShowcase> list = new ArrayList<>();
                while (rs.next()) {
                    CustomShowcase c = new CustomShowcase();
                    c.setReviewId(rs.getInt("review_id"));
                    c.setImageUrl(rs.getString("image_url"));
                    c.setRating(rs.getInt("rating"));
                    c.setContent(rs.getString("content"));
                    c.setWriterName(rs.getString("writer_name"));
                    c.setOptions(rs.getString("options"));
                    c.setLettering(rs.getString("lettering"));
                    Date d = rs.getDate("pickup_date");
                    if (d != null) c.setPickupDate(d.toLocalDate());
                    list.add(c);
                }
                return list;
            }
        }
    }
}
