package com.minecake.dto;

/** 주문 상세 (order_item 테이블) */
public class OrderItem {
    private int orderItemId;
    private int orderId;
    private int productId;
    private String options;
    private String lettering;
    private String request;
    private int quantity;
    private int price;

    public OrderItem() {}

    public int getOrderItemId() { return orderItemId; }
    public void setOrderItemId(int orderItemId) { this.orderItemId = orderItemId; }

    public int getOrderId() { return orderId; }
    public void setOrderId(int orderId) { this.orderId = orderId; }

    public int getProductId() { return productId; }
    public void setProductId(int productId) { this.productId = productId; }

    public String getOptions() { return options; }
    public void setOptions(String options) { this.options = options; }

    public String getLettering() { return lettering; }
    public void setLettering(String lettering) { this.lettering = lettering; }

    public String getRequest() { return request; }
    public void setRequest(String request) { this.request = request; }

    public int getQuantity() { return quantity; }
    public void setQuantity(int quantity) { this.quantity = quantity; }

    public int getPrice() { return price; }
    public void setPrice(int price) { this.price = price; }
}
