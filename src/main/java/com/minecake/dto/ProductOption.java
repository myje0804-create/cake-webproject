package com.minecake.dto;

/** 커스텀 옵션 (product_option 테이블) */
public class ProductOption {
    private int optionId;
    private String optionType;   // SIZE / FLAVOR / CREAM_COLOR / DECO
    private String name;
    private int extraPrice;   // 추가 금액

    public ProductOption() {}

    public int getOptionId() { return optionId; }
    public void setOptionId(int optionId) { this.optionId = optionId; }

    public String getOptionType() { return optionType; }
    public void setOptionType(String optionType) { this.optionType = optionType; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public int getExtraPrice() { return extraPrice; }
    public void setExtraPrice(int extraPrice) { this.extraPrice = extraPrice; }
}
