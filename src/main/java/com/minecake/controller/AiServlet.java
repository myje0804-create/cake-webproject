package com.minecake.controller;

import java.io.IOException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.time.Duration;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.nio.charset.StandardCharsets;
import java.io.PrintWriter;
import java.net.URI;



/**
 * AiServlet — 역할 C
 * 할 일: 입력값으로 프롬프트 생성 → GemmaClient 호출 → 추천 결과 전달
 * 주소 예시: /ai/recommend?action=list
 */
@WebServlet("/ai/recommend")
public class AiServlet extends HttpServlet {
    private static final String OLLAMA_GENERATE_URL = "";
    private static final String MODEL_NAME = "";

    private final HttpClient httpClient = HttpClient.newBuilder()
            .connectTimeout(Duration.ofSeconds(10))
            .build();
    
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        req.getRequestDispatcher("/ai/aiCake.jsp").forward(req, resp); // [수정] JSP 화면으로 포워딩 추가
        // TODO: action 값에 따라 DAO 호출 → req.setAttribute(...) → JSP로 forward
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        resp.setCharacterEncoding(StandardCharsets.UTF_8.name()); // [수정] JSON 헤더 제거 및 응답 인코딩 지정
       
        String product = req.getParameter("product");
        String answer = "";
        String error = "";

        if (product == null || product.isBlank()) {
            error = "상품 정보를 입력해 주세요.";
        } else {
        String basePrompt = "당신은 케이크 전문가입니다.\n"
        + "아래 조건에 맞춰 케이크 레터링 문구나 분위기를 추천해 주세요.\n\n"
        + "[조건]\n"
        + "1. 15자 이내의 짧고 감성적인 문구일 것\n"
        + "2. 불필요한 인사말 없이 문구만 출력할 것\n"
        + "3. 설명은 최대한 적게, 추천되는 문구만 출력할 것\n"
        + "4. 질문에 가장 적합한 답변을 출력할 것\n"
        + "5. 분위기 질문에 답변할 때도 문구와 같은 조건을 적용시킬 것";
        String fullPrompt = basePrompt + "\n대상 상품: " + product.trim();

        String requestBody = String.format(
                "{\"model\":\"%s\",\"prompt\":\"%s\",\"stream\":false}",
                escapeJson(MODEL_NAME),
                escapeJson(fullPrompt)
        );
        try {
            HttpRequest request = HttpRequest.newBuilder()
                    .uri(URI.create(OLLAMA_GENERATE_URL))
                    .header("Content-Type", "application/json; charset=UTF-8")
                    .timeout(Duration.ofSeconds(60))
                    .POST(HttpRequest.BodyPublishers.ofString(requestBody, StandardCharsets.UTF_8))
                    .build();

            HttpResponse<String> response = httpClient.send(
                    request, HttpResponse.BodyHandlers.ofString(StandardCharsets.UTF_8));

            if (response.statusCode() != 200) {
                    error = "Gemma3 호출 실패 (HTTP " + response.statusCode() + ")";
                } else {
                    answer = extractResponseField(response.body());
                }
            } catch (InterruptedException e) {
                Thread.currentThread().interrupt();
                error = "요청 처리가 중단되었습니다.";
            } catch (Exception e) {
                e.printStackTrace();
    String msg = e.getMessage();
    String detail = (msg != null && !msg.isBlank())
            ? msg
            : e.getClass().getName();
    error = "답변 생성 실패: " + detail;
}
        }
        String cakeId = req.getParameter("id");
            if (cakeId == null || cakeId.isBlank()) {
            cakeId = req.getParameter("product_id");
        }    // [추가]
        req.setAttribute("id", cakeId == null ? "" : cakeId.trim());
        req.setAttribute("product", product == null ? "" : product.trim());
        req.setAttribute("answer", answer);
        req.setAttribute("error", error);

        req.getRequestDispatcher("/ai/aiCake.jsp").forward(req, resp);
    
    }
    

    private String extractResponseField(String jsonBody) {
        Pattern pattern = Pattern.compile("\"response\"\\s*:\\s*\"((?:\\\\.|[^\"\\\\])*)\"");
        Matcher matcher = pattern.matcher(jsonBody);
        if (matcher.find()) {
            return unescapeJson(matcher.group(1));
        }
        return jsonBody;
    }

    private String escapeJson(String text) {
        if (text == null) {
            return "";
        }
        StringBuilder sb = new StringBuilder(text.length());
        for (int i = 0; i < text.length(); i++) {
            char c = text.charAt(i);
            switch (c) {
                case '"' -> sb.append("\\\"");
                case '\\' -> sb.append("\\\\");
                case '\n' -> sb.append("\\n");
                case '\r' -> sb.append("\\r");
                case '\t' -> sb.append("\\t");
                default -> sb.append(c);
            }
        }
        return sb.toString();
    }

    private String unescapeJson(String text) {
        return text
                .replace("\\n", "\n")
                .replace("\\r", "\r")
                .replace("\\t", "\t")
                .replace("\\\"", "\"")
                .replace("\\\\", "\\");
    }
}
