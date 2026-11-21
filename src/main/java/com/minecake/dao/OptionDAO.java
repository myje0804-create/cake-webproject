package com.minecake.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import com.minecake.dto.ProductOption;
import com.minecake.util.DBUtil;

/**
 * OptionDAO — 역할 B (3주차 · 옵션별 추가 금액 계산)
 * product_option 테이블 조회. 커스텀 화면(역할 A)도 옵션 목록을 그릴 때 findAll()을 쓰면 됨.
 */
public class OptionDAO {

    /** 화면에 보여줄 전체 옵션 (종류 순서: 크기 → 맛 → 크림 색 → 장식) */
    public List<ProductOption> findAll() throws SQLException {
        String sql = "SELECT option_id, option_type, name, extra_price FROM product_option "
                   + "ORDER BY FIELD(option_type, 'SIZE', 'FLAVOR', 'CREAM_COLOR', 'DECO'), option_id";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            List<ProductOption> list = new ArrayList<>();
            while (rs.next()) list.add(map(rs));
            return list;
        }
    }

    /** 고객이 고른 옵션 번호들로 실제 옵션(이름·추가 금액)을 DB에서 다시 꺼냄 */
    public List<ProductOption> findByIds(List<Integer> ids) throws SQLException {
        List<ProductOption> list = new ArrayList<>();
        if (ids == null || ids.isEmpty()) return list;

        StringBuilder sql = new StringBuilder(
            "SELECT option_id, option_type, name, extra_price FROM product_option WHERE option_id IN (");
        for (int i = 0; i < ids.size(); i++) sql.append(i == 0 ? "?" : ", ?");
        sql.append(") ORDER BY FIELD(option_type, 'SIZE', 'FLAVOR', 'CREAM_COLOR', 'DECO')");

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < ids.size(); i++) ps.setInt(i + 1, ids.get(i));
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(map(rs));
            }
        }
        return list;
    }

    private ProductOption map(ResultSet rs) throws SQLException {
        ProductOption o = new ProductOption();
        o.setOptionId(rs.getInt("option_id"));
        o.setOptionType(rs.getString("option_type"));
        o.setName(rs.getString("name"));
        o.setExtraPrice(rs.getInt("extra_price"));
        return o;
    }
}
