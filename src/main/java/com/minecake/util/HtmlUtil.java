package com.minecake.util;

/**
 * 사용자가 입력한 글자(레터링, 요청사항 등)를 화면에 출력할 때 쓰는 도우미
 * <script> 같은 글자를 그대로 출력하면 화면이 깨지거나 악성 코드가 실행될 수 있어서
 * < > & " ' 를 안전한 글자로 바꿔서 출력함.
 *
 * JSP에서 사용: <%= HtmlUtil.escape(item.getLettering()) %>
 */
public class HtmlUtil {

    public static String escape(String s) {
        if (s == null) return "";
        StringBuilder sb = new StringBuilder(s.length());
        for (char c : s.toCharArray()) {
            switch (c) {
                case '<':  sb.append("&lt;"); break;
                case '>':  sb.append("&gt;"); break;
                case '&':  sb.append("&amp;"); break;
                case '"':  sb.append("&quot;"); break;
                case '\'': sb.append("&#39;"); break;
                default:   sb.append(c);
            }
        }
        return sb.toString();
    }

    /** 숫자를 21,000 처럼 쉼표 넣어서 보여주기 */
    public static String won(int price) {
        return String.format("%,d", price);
    }
}
