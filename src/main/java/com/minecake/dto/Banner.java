package com.minecake.dto;

/** 메인 배너 (banner 테이블) */
public class Banner {
    private int bannerId;
    private String eyebrow;   // 작은 글씨
    private String title;
    private String description;
    private String imageUrl;
    private String linkUrl;   // 클릭 시 이동
    private int sortOrder;

    public Banner() {}

    public int getBannerId() { return bannerId; }
    public void setBannerId(int bannerId) { this.bannerId = bannerId; }

    public String getEyebrow() { return eyebrow; }
    public void setEyebrow(String eyebrow) { this.eyebrow = eyebrow; }

    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public String getImageUrl() { return imageUrl; }
    public void setImageUrl(String imageUrl) { this.imageUrl = imageUrl; }

    public String getLinkUrl() { return linkUrl; }
    public void setLinkUrl(String linkUrl) { this.linkUrl = linkUrl; }

    public int getSortOrder() { return sortOrder; }
    public void setSortOrder(int sortOrder) { this.sortOrder = sortOrder; }
}
