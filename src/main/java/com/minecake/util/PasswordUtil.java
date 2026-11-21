package com.minecake.util;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;

/**
 * 비밀번호를 그대로 저장하지 않고 SHA-256으로 바꿔서 저장하는 도우미 — 역할 B
 *
 * 비유: 비밀번호를 믹서기에 갈아서 저장하는 것.
 * 같은 비밀번호는 항상 같은 결과가 나오지만, 결과만 보고 원래 비밀번호를 알아낼 수는 없음.
 * 로그인할 때는 입력한 비밀번호도 똑같이 갈아서 DB 값과 비교함.
 */
public class PasswordUtil {

    public static String hash(String rawPassword) {
        try {
            MessageDigest md = MessageDigest.getInstance("SHA-256");
            byte[] bytes = md.digest(rawPassword.getBytes(StandardCharsets.UTF_8));
            StringBuilder sb = new StringBuilder();
            for (byte b : bytes) {
                sb.append(String.format("%02x", b));
            }
            return sb.toString();   // 64글자 16진수 문자열
        } catch (NoSuchAlgorithmException e) {
            throw new RuntimeException("SHA-256을 사용할 수 없어요.", e);
        }
    }
}
