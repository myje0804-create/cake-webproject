-- =========================================================
-- 11/21 이전에 sample_data.sql을 이미 실행한 사람만 1번 실행
-- 시연 계정 비밀번호를 SHA-256 값으로 바꿔서, 새 로그인 기능으로 로그인되게 함
--   admin / admin1234     yeji / 1234
-- =========================================================
USE minecake;
SET SQL_SAFE_UPDATES = 0;
UPDATE member SET password = 'ac9689e2272427085e35b9d3e3e8bed88cb3434828b43b86fc0596cad4c6e270' WHERE login_id = 'admin';
UPDATE member SET password = '03ac674216f3e15c761ee1a5e255f067953623c8b388b4459e13f978d7c846f4' WHERE login_id = 'yeji';
SET SQL_SAFE_UPDATES = 1;
