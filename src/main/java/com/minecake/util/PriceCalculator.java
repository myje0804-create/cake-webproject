package com.minecake.util;

import java.util.List;

import com.minecake.dto.ProductOption;

/**
 * 커스텀 케이크 1개 가격 계산 — 역할 B (3주차 · 옵션별 추가 금액 계산)
 *
 * 1개 가격 = 상품 기본 가격 + 선택한 옵션들의 추가 금액 + 레터링 추가금
 *
 * ⚠ 가격은 꼭 서버(여기)에서 계산해야 함.
 *   화면(JS)에서 계산한 금액을 그대로 믿으면, 누군가 개발자 도구로 금액을 0원으로 바꿔서 보낼 수 있음.
 */
public class PriceCalculator {

    /** 레터링이 이 글자 수를 넘으면 추가금 */
    public static final int FREE_LETTERING_LENGTH = 10;
    public static final int LETTERING_EXTRA_PRICE = 1000;
    public static final int MAX_LETTERING_LENGTH = 20;

    public static int unitPrice(int basePrice, List<ProductOption> options, String lettering) {
        int price = basePrice;
        for (ProductOption option : options) {
            price += option.getExtraPrice();
        }
        price += letteringExtra(lettering);
        return price;
    }

    public static int letteringExtra(String lettering) {
        if (lettering == null) return 0;
        return lettering.length() > FREE_LETTERING_LENGTH ? LETTERING_EXTRA_PRICE : 0;
    }
}
