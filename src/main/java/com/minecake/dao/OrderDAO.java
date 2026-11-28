package com.minecake.dao;

import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Time;
import java.sql.Timestamp;
import java.time.LocalDate;
import java.time.LocalTime;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import com.minecake.dto.Order;
import com.minecake.dto.OrderItem;
import com.minecake.util.DBUtil;

/**
 * OrderDAO — 역할 B (예지)
 * 주문 저장 · 내 주문 목록 · 주문 1건 조회
 * + 관리자용(선우): 전체 주문 목록 · 제작 상태 변경
 *
 * 주문 저장은 "트랜잭션"으로 처리:
 *   장바구니 읽기 → orders 저장 → order_item 저장 → 장바구니 비우기
 *   중간에 하나라도 실패하면 전부 취소(rollback) → 돈은 냈는데 주문이 반만 저장되는 일 없음
 */
public class OrderDAO {

    /**
     * 내 장바구니를 주문으로 바꿔 저장
     * @return 새 주문 번호 (장바구니가 비어 있으면 -1)
     */
    public int placeOrder(int memberId, LocalDate pickupDate, LocalTime pickupTime) throws SQLException {
        try (Connection conn = DBUtil.getConnection()) {
            conn.setAutoCommit(false);
            try {
                // 1) 장바구니 읽기 (FOR UPDATE: 저장하는 동안 다른 요청이 같은 장바구니를 못 건드리게 잠금)
                List<OrderItem> items = new ArrayList<>();
                String cartSql = "SELECT product_id, options, lettering, request, quantity, price "
                               + "FROM cart WHERE member_id = ? ORDER BY cart_id FOR UPDATE";
                try (PreparedStatement ps = conn.prepareStatement(cartSql)) {
                    ps.setInt(1, memberId);
                    try (ResultSet rs = ps.executeQuery()) {
                        while (rs.next()) {
                            OrderItem it = new OrderItem();
                            it.setProductId(rs.getInt("product_id"));
                            it.setOptions(rs.getString("options"));
                            it.setLettering(rs.getString("lettering"));
                            it.setRequest(rs.getString("request"));
                            it.setQuantity(rs.getInt("quantity"));
                            it.setPrice(rs.getInt("price"));
                            items.add(it);
                        }
                    }
                }
                if (items.isEmpty()) {          // 이미 주문했거나(두 번 클릭) 비어 있음
                    conn.rollback();
                    return -1;
                }

                // 2) 합계는 서버에서 다시 계산 (화면에서 보낸 금액은 믿지 않음)
                int total = 0;
                for (OrderItem it : items) total += it.getLineTotal();

                // 3) orders 저장
                int orderId;
                String orderSql = "INSERT INTO orders (member_id, total_price, pickup_date, pickup_time, status) "
                                + "VALUES (?, ?, ?, ?, ?)";
                try (PreparedStatement ps = conn.prepareStatement(orderSql, Statement.RETURN_GENERATED_KEYS)) {
                    ps.setInt(1, memberId);
                    ps.setInt(2, total);
                    ps.setDate(3, Date.valueOf(pickupDate));
                    ps.setTime(4, Time.valueOf(pickupTime));
                    ps.setString(5, Order.RECEIVED);
                    ps.executeUpdate();
                    try (ResultSet keys = ps.getGeneratedKeys()) {
                        keys.next();
                        orderId = keys.getInt(1);
                    }
                }

                // 4) order_item 저장 (주문 당시 옵션·레터링·가격 그대로)
                String itemSql = "INSERT INTO order_item (order_id, product_id, options, lettering, request, quantity, price) "
                               + "VALUES (?, ?, ?, ?, ?, ?, ?)";
                try (PreparedStatement ps = conn.prepareStatement(itemSql)) {
                    for (OrderItem it : items) {
                        ps.setInt(1, orderId);
                        ps.setInt(2, it.getProductId());
                        ps.setString(3, it.getOptions());
                        ps.setString(4, it.getLettering());
                        ps.setString(5, it.getRequest());
                        ps.setInt(6, it.getQuantity());
                        ps.setInt(7, it.getPrice());
                        ps.addBatch();
                    }
                    ps.executeBatch();
                }

                // 5) 장바구니 비우기
                try (PreparedStatement ps = conn.prepareStatement("DELETE FROM cart WHERE member_id = ?")) {
                    ps.setInt(1, memberId);
                    ps.executeUpdate();
                }

                conn.commit();
                return orderId;
            } catch (SQLException e) {
                conn.rollback();
                throw e;
            }
        }
    }

    /** 내 주문 목록 (최근 주문 먼저, 케이크 목록 포함) */
    public List<Order> findByMember(int memberId) throws SQLException {
        String sql = "SELECT * FROM orders WHERE member_id = ? ORDER BY order_id DESC";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, memberId);
            return withItems(conn, readOrders(ps));
        }
    }

    /** 주문 1건 (내 주문일 때만. 남의 주문이면 null) */
    public Order findById(int orderId, int memberId) throws SQLException {
        String sql = "SELECT * FROM orders WHERE order_id = ? AND member_id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, orderId);
            ps.setInt(2, memberId);
            List<Order> list = withItems(conn, readOrders(ps));
            return list.isEmpty() ? null : list.get(0);
        }
    }

    // ---------------- 관리자용 (선우) ----------------

    /** 전체 주문 목록 (최근 주문 먼저, 케이크 목록 포함) */
    public List<Order> findAll() throws SQLException {
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement("SELECT * FROM orders ORDER BY order_id DESC")) {
            return withItems(conn, readOrders(ps));
        }
    }

    /** 제작 상태 변경 (RECEIVED / MAKING / READY / PICKED_UP 만 허용) */
    public int updateStatus(int orderId, String status) throws SQLException {
        boolean valid = false;
        for (String s : Order.STATUS_FLOW) if (s.equals(status)) valid = true;
        if (!valid) return 0;
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement("UPDATE orders SET status = ? WHERE order_id = ?")) {
            ps.setString(1, status);
            ps.setInt(2, orderId);
            return ps.executeUpdate();
        }
    }

    // ---------------- 도우미 ----------------

    private List<Order> readOrders(PreparedStatement ps) throws SQLException {
        List<Order> list = new ArrayList<>();
        try (ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Order o = new Order();
                o.setOrderId(rs.getInt("order_id"));
                o.setMemberId(rs.getInt("member_id"));
                o.setTotalPrice(rs.getInt("total_price"));
                Date d = rs.getDate("pickup_date");
                if (d != null) o.setPickupDate(d.toLocalDate());
                Time t = rs.getTime("pickup_time");
                if (t != null) o.setPickupTime(t.toLocalTime());
                o.setStatus(rs.getString("status"));
                Timestamp at = rs.getTimestamp("ordered_at");
                if (at != null) o.setOrderedAt(at.toLocalDateTime());
                list.add(o);
            }
        }
        return list;
    }

    /** 주문들에 담긴 케이크(order_item + 상품 이름·사진)를 한 번에 채움 */
    private List<Order> withItems(Connection conn, List<Order> orders) throws SQLException {
        if (orders.isEmpty()) return orders;
        Map<Integer, Order> byId = new LinkedHashMap<>();
        StringBuilder in = new StringBuilder();
        for (Order o : orders) {
            byId.put(o.getOrderId(), o);
            if (in.length() > 0) in.append(',');
            in.append('?');
        }
        String sql = "SELECT oi.*, p.name AS product_name, p.image_url "
                   + "FROM order_item oi JOIN product p ON oi.product_id = p.product_id "
                   + "WHERE oi.order_id IN (" + in + ") ORDER BY oi.order_item_id";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            int i = 1;
            for (Integer id : byId.keySet()) ps.setInt(i++, id);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    OrderItem it = new OrderItem();
                    it.setOrderItemId(rs.getInt("order_item_id"));
                    it.setOrderId(rs.getInt("order_id"));
                    it.setProductId(rs.getInt("product_id"));
                    it.setProductName(rs.getString("product_name"));
                    it.setImageUrl(rs.getString("image_url"));
                    it.setOptions(rs.getString("options"));
                    it.setLettering(rs.getString("lettering"));
                    it.setRequest(rs.getString("request"));
                    it.setQuantity(rs.getInt("quantity"));
                    it.setPrice(rs.getInt("price"));
                    byId.get(it.getOrderId()).getItems().add(it);
                }
            }
        }
        return orders;
    }
}
