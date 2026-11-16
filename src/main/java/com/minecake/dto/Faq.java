package com.minecake.dto;

/** 자주 묻는 질문 (faq 테이블) */
public class Faq {
    private int faqId;
    private String question;
    private String answer;

    public Faq() {}

    public int getFaqId() { return faqId; }
    public void setFaqId(int faqId) { this.faqId = faqId; }

    public String getQuestion() { return question; }
    public void setQuestion(String question) { this.question = question; }

    public String getAnswer() { return answer; }
    public void setAnswer(String answer) { this.answer = answer; }
}
