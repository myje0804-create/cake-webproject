package com.minecake.dto;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;

/** 케이크·추가상품 (product 테이블) */
public class Product {
    private int productId;
    private String type;   // CAKE / ADDON
    private String category;   // LETTERING / CHARACTER / LUNCHBOX / FLOWER / SEASON
    private String name;
    private int price;   // 시작 가격
    private String description;
    private String imageUrl;
    private boolean best;   // 메인 Best Design 노출 여부
    private int reviewCount;   // 정렬용
    private LocalDateTime createdAt;

    public Product() {}

    public int getProductId() { return productId; }
    public void setProductId(int productId) { this.productId = productId; }

    public String getType() { return type; }
    public void setType(String type) { this.type = type; }

    public String getCategory() { return category; }
    public void setCategory(String category) { this.category = category; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public int getPrice() { return price; }
    public void setPrice(int price) { this.price = price; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public String getImageUrl() { return imageUrl; }
    public void setImageUrl(String imageUrl) { this.imageUrl = imageUrl; }

    public boolean getBest() { return best; }
    public void setBest(boolean best) { this.best = best; }

    public int getReviewCount() { return reviewCount; }
    public void setReviewCount(int reviewCount) { this.reviewCount = reviewCount; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
}
