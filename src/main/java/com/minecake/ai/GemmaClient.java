package com.minecake.ai;


/**
 * GemmaClient — 역할 C
 * Gemma 3 API를 호출해서 케이크 디자인·문구 추천을 받아오는 클래스
 * API 키는 코드에 쓰지 말고 환경변수 GEMMA_API_KEY에서 읽기 (깃허브에 키가 올라가면 안 됨!)
 */
public class GemmaClient {
    private final String apiKey = System.getenv("GEMMA_API_KEY");

    // TODO: recommend(상황, 받는 사람, 분위기, 요청사항) → 추천 결과 문자열(JSON) 반환
}
