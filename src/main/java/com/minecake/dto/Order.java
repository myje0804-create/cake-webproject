package com.minecake.dto;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.ArrayList;
import java.util.List;

/** 주문 (orders 테이블) */
public class Order {
    /** 제작 상태 4단계 (관리자 화면에서 이 값으로 바꾸면 마이페이지에 그대로 보임) */
    public static final String RECEIVED  = "RECEIVED";   // 주문 접수
    public static final String MAKING    = "MAKING";     // 제작 중
    public static final String READY     = "READY";      // 픽업 대기
    public static final String PICKED_UP = "PICKED_UP";  // 픽업 완료
    public static final String[] STATUS_FLOW = { RECEIVED, MAKING, READY, PICKED_UP };

    private int orderId;
    private int memberId;
    private int totalPrice;
    private LocalDate pickupDate;
    private LocalTime pickupTime;
    private String status;   // RECEIVED / MAKING / READY / PICKED_UP
    private LocalDateTime orderedAt;
    private List<OrderItem> items = new ArrayList<>();   // 화면 표시용 (주문에 담긴 케이크들)

    public Order() {}

    /** 상태를 화면에 보일 한글로 */
    public static String statusLabel(String status) {
        if (status == null) return "주문 접수";
        switch (status) {
            case MAKING:    return "제작 중";
            case READY:     return "픽업 대기";
            case PICKED_UP: return "픽업 완료";
            default:        return "주문 접수";
        }
    }
    public String getStatusLabel() { return statusLabel(status); }

    /** 4단계 중 몇 번째인지 (0~3) — 마이페이지 진행 막대용 */
    public int getStatusStep() {
        for (int i = 0; i < STATUS_FLOW.length; i++) {
            if (STATUS_FLOW[i].equals(status)) return i;
        }
        return 0;
    }

    /** "케이크 이름 외 2건" 같은 요약 */
    public String getSummaryName() {
        if (items.isEmpty()) return "주문 #" + orderId;
        String first = items.get(0).getProductName();
        return items.size() == 1 ? first : first + " 외 " + (items.size() - 1) + "건";
    }

    public int getOrderId() { return orderId; }
    public void setOrderId(int orderId) { this.orderId = orderId; }

    public int getMemberId() { return memberId; }
    public void setMemberId(int memberId) { this.memberId = memberId; }

    public int getTotalPrice() { return totalPrice; }
    public void setTotalPrice(int totalPrice) { this.totalPrice = totalPrice; }

    public LocalDate getPickupDate() { return pickupDate; }
    public void setPickupDate(LocalDate pickupDate) { this.pickupDate = pickupDate; }

    public LocalTime getPickupTime() { return pickupTime; }
    public void setPickupTime(LocalTime pickupTime) { this.pickupTime = pickupTime; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public LocalDateTime getOrderedAt() { return orderedAt; }
    public void setOrderedAt(LocalDateTime orderedAt) { this.orderedAt = orderedAt; }

    public List<OrderItem> getItems() { return items; }
    public void setItems(List<OrderItem> items) { this.items = items; }
}
