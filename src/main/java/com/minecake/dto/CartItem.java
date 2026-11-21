package com.minecake.dto;

/** 장바구니 (cart 테이블) */
public class CartItem {
    private int cartId;
    private int memberId;
    private int productId;
    private String productName;   // 화면 표시용
    private String imageUrl;   // 화면 표시용 (product 테이블에서 같이 가져옴)
    private String options;   // 선택 옵션 요약
    private String lettering;
    private String request;   // 요청사항
    private int quantity;
    private int price;   // 옵션 포함 1개 가격

    public CartItem() {}

    public int getCartId() { return cartId; }
    public void setCartId(int cartId) { this.cartId = cartId; }

    public int getMemberId() { return memberId; }
    public void setMemberId(int memberId) { this.memberId = memberId; }

    public int getProductId() { return productId; }
    public void setProductId(int productId) { this.productId = productId; }

    public String getProductName() { return productName; }
    public void setProductName(String productName) { this.productName = productName; }

    public String getImageUrl() { return imageUrl; }
    public void setImageUrl(String imageUrl) { this.imageUrl = imageUrl; }

    /** 이 항목의 합계 = 1개 가격 × 수량 */
    public int getLineTotal() { return price * quantity; }

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
