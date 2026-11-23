package com.minecake.dto;

/** 상품 사진 1장 (product_image 테이블) */
public class ProductImage {
    private int imageId;
    private int productId;
    private String viewType;   // MAIN(대표) / SIDE(옆모습) / TOP(위에서)
    private String imageUrl;

    public ProductImage() {}

    public int getImageId() { return imageId; }
    public void setImageId(int imageId) { this.imageId = imageId; }

    public int getProductId() { return productId; }
    public void setProductId(int productId) { this.productId = productId; }

    public String getViewType() { return viewType; }
    public void setViewType(String viewType) { this.viewType = viewType; }

    public String getImageUrl() { return imageUrl; }
    public void setImageUrl(String imageUrl) { this.imageUrl = imageUrl; }

    /** 화면에 보일 이름 */
    public String getViewLabel() {
        if ("SIDE".equals(viewType)) return "옆모습";
        if ("TOP".equals(viewType)) return "위에서 본 모습";
        return "대표 사진";
    }
}
