package com.minecake.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

import com.minecake.dto.Member;
import com.minecake.util.DBUtil;
import com.minecake.util.PasswordUtil;

/**
 * MemberDAO — 역할 B
 * 회원가입, 아이디 중복 확인, 로그인 확인
 * (회원 정보 수정 · 관리자 회원 목록은 이후 주차에 추가)
 */
public class MemberDAO {

    /** 이미 있는 아이디인지 확인 */
    public boolean existsLoginId(String loginId) throws SQLException {
        String sql = "SELECT 1 FROM member WHERE login_id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, loginId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }

    /** 회원가입: 비밀번호는 SHA-256으로 바꿔서 저장 */
    public int insert(Member m, String rawPassword) throws SQLException {
        String sql = "INSERT INTO member (login_id, password, name, phone, email, role) "
                   + "VALUES (?, ?, ?, ?, ?, 'USER')";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, m.getLoginId());
            ps.setString(2, PasswordUtil.hash(rawPassword));
            ps.setString(3, m.getName());
            ps.setString(4, m.getPhone());
            ps.setString(5, m.getEmail());
            return ps.executeUpdate();
        }
    }

    /**
     * 로그인: 아이디와 (바꾼) 비밀번호가 둘 다 맞는 회원을 찾음
     * @return 맞으면 회원 정보, 틀리면 null
     */
    public Member login(String loginId, String rawPassword) throws SQLException {
        String sql = "SELECT member_id, login_id, name, phone, email, role "
                   + "FROM member WHERE login_id = ? AND password = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, loginId);
            ps.setString(2, PasswordUtil.hash(rawPassword));
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) return null;
                Member m = new Member();
                m.setMemberId(rs.getInt("member_id"));
                m.setLoginId(rs.getString("login_id"));
                m.setName(rs.getString("name"));
                m.setPhone(rs.getString("phone"));
                m.setEmail(rs.getString("email"));
                m.setRole(rs.getString("role"));
                return m;   // 비밀번호는 세션에 담지 않음
            }
        }
    }
}
