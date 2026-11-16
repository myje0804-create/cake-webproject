package com.minecake.util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

/**
 * DB 연결 도우미. 모든 DAO가 DBUtil.getConnection()으로 연결을 받아 씀.
 * 각자 PC의 MySQL 비밀번호가 다르면 PASSWORD만 바꾸고, 이 파일은 커밋하지 않기!
 */
public class DBUtil {
    private static final String URL =
        "jdbc:mysql://localhost:3306/minecake?serverTimezone=Asia/Seoul&characterEncoding=UTF-8";
    private static final String USER = "root";
    private static final String PASSWORD = "1234";

    static {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            throw new RuntimeException("MySQL 드라이버를 찾을 수 없어요. pom.xml을 확인하세요.", e);
        }
    }

    public static Connection getConnection() throws SQLException {
        return DriverManager.getConnection(URL, USER, PASSWORD);
    }
}
