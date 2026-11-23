package com.minecake.dto;

import java.time.LocalDate;

/**
 * "다른 고객님들의 커스텀" 카드 1개
 * 사진 후기(review) + 그 주문에서 고른 옵션·레터링(order_item)을 묶은 것
 */
public class CustomShowcase {
    private int reviewId;
    private String imageUrl;
    private int rating;
    private String content;
    private String writerName;   // 화면에는 가운데 글자를 가려서 보여줌
    private String options;
    private String lettering;
    private LocalDate pickupDate;

    public CustomShowcase() {}

    /** 이름 가운데를 * 로 가리기: 김민지 → 김*지, 이준 → 이* */
    public String getMaskedWriter() {
        if (writerName == null || writerName.isEmpty()) return "고객";
        if (writerName.length() == 1) return writerName;
        if (writerName.length() == 2) return writerName.charAt(0) + "*";
        return writerName.charAt(0) + "*".repeat(writerName.length() - 2) + writerName.charAt(writerName.length() - 1);
    }

    public int getReviewId() { return reviewId; }
    public void setReviewId(int reviewId) { this.reviewId = reviewId; }

    public String getImageUrl() { return imageUrl; }
    public void setImageUrl(String imageUrl) { this.imageUrl = imageUrl; }

    public int getRating() { return rating; }
    public void setRating(int rating) { this.rating = rating; }

    public String getContent() { return content; }
    public void setContent(String content) { this.content = content; }

    public String getWriterName() { return writerName; }
    public void setWriterName(String writerName) { this.writerName = writerName; }

    public String getOptions() { return options; }
    public void setOptions(String options) { this.options = options; }

    public String getLettering() { return lettering; }
    public void setLettering(String lettering) { this.lettering = lettering; }

    public LocalDate getPickupDate() { return pickupDate; }
    public void setPickupDate(LocalDate pickupDate) { this.pickupDate = pickupDate; }
}
