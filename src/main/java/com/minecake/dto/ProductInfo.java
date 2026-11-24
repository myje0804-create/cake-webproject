package com.minecake.dto;

import java.util.ArrayList;
import java.util.List;

/** 상품 상세 정보: 원재료·원산지·영양성분·알레르기·보관 (product_info 테이블) */
public class ProductInfo {
    private int productId;
    private String ingredients;    // 한 줄에 하나: "재료|원산지·설명"
    private String allergens;      // 쉼표로 구분
    private String servingBasis;   // 예: 100g당
    private Integer kcal;
    private Double sugarG;
    private Double proteinG;
    private Double fatG;
    private Double satFatG;
    private Integer sodiumMg;
    private String storage;

    public ProductInfo() {}

    /** 원재료 목록을 [재료, 원산지] 쌍으로 나눠서 돌려줌 (화면 표에 쓰기 좋게) */
    public List<String[]> getIngredientRows() {
        List<String[]> rows = new ArrayList<>();
        if (ingredients == null) return rows;
        for (String line : ingredients.split("\\r?\\n")) {
            if (line.trim().isEmpty()) continue;
            String[] parts = line.split("\\|", 2);
            rows.add(new String[] { parts[0].trim(), parts.length > 1 ? parts[1].trim() : "" });
        }
        return rows;
    }

    /** 알레르기 성분을 하나씩 나눠서 돌려줌 */
    public List<String> getAllergenList() {
        List<String> list = new ArrayList<>();
        if (allergens == null) return list;
        for (String a : allergens.split(",")) {
            if (!a.trim().isEmpty()) list.add(a.trim());
        }
        return list;
    }

    /** 영양성분이 하나라도 있는지 */
    public boolean hasNutrition() {
        return kcal != null || sugarG != null || proteinG != null || fatG != null || sodiumMg != null;
    }

    public int getProductId() { return productId; }
    public void setProductId(int productId) { this.productId = productId; }

    public String getIngredients() { return ingredients; }
    public void setIngredients(String ingredients) { this.ingredients = ingredients; }

    public String getAllergens() { return allergens; }
    public void setAllergens(String allergens) { this.allergens = allergens; }

    public String getServingBasis() { return servingBasis; }
    public void setServingBasis(String servingBasis) { this.servingBasis = servingBasis; }

    public Integer getKcal() { return kcal; }
    public void setKcal(Integer kcal) { this.kcal = kcal; }

    public Double getSugarG() { return sugarG; }
    public void setSugarG(Double sugarG) { this.sugarG = sugarG; }

    public Double getProteinG() { return proteinG; }
    public void setProteinG(Double proteinG) { this.proteinG = proteinG; }

    public Double getFatG() { return fatG; }
    public void setFatG(Double fatG) { this.fatG = fatG; }

    public Double getSatFatG() { return satFatG; }
    public void setSatFatG(Double satFatG) { this.satFatG = satFatG; }

    public Integer getSodiumMg() { return sodiumMg; }
    public void setSodiumMg(Integer sodiumMg) { this.sodiumMg = sodiumMg; }

    public String getStorage() { return storage; }
    public void setStorage(String storage) { this.storage = storage; }
}
