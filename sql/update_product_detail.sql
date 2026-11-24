-- =========================================================
-- 11/23 상품 상세 정보 추가 — 이미 minecake DB가 있는 사람만 1번 실행
-- (처음 만드는 사람은 schema.sql → sample_data.sql만 실행하면 이미 포함돼 있음)
-- 새 테이블: product_image(사진 여러 장), product_info(원재료·영양성분)
-- 예시 데이터: 상품 사진 경로, 원재료·영양성분, 예시 회원 3명·픽업 완료 주문·사진 후기
-- ⚠ 두 번 실행하면 예시 회원이 이미 있다는 오류(Duplicate entry)가 나요
-- =========================================================
USE minecake;

-- 상품 사진 여러 장 (대표 · 옆모습 · 위에서 본 모습)
CREATE TABLE IF NOT EXISTS product_image (
  image_id    INT AUTO_INCREMENT PRIMARY KEY,
  product_id  INT NOT NULL,
  view_type   VARCHAR(10) NOT NULL DEFAULT 'MAIN',        -- MAIN(대표) / SIDE(옆모습) / TOP(위에서)
  image_url   VARCHAR(255) NOT NULL,
  sort_order  INT NOT NULL DEFAULT 0,
  FOREIGN KEY (product_id) REFERENCES product(product_id) ON DELETE CASCADE
);

-- 상품 상세 정보 (원재료·원산지·영양성분·알레르기·보관)
CREATE TABLE IF NOT EXISTS product_info (
  product_id    INT PRIMARY KEY,
  ingredients   TEXT,                 -- 원재료와 원산지 (한 줄에 하나: "재료|원산지·설명")
  allergens     VARCHAR(100),         -- 알레르기 유발 성분 (쉼표로 구분)
  serving_basis VARCHAR(50),          -- 영양성분 기준 (예: 100g당)
  kcal          INT,
  sugar_g       DECIMAL(5,1),
  protein_g     DECIMAL(5,1),
  fat_g         DECIMAL(5,1),
  sat_fat_g     DECIMAL(5,1),
  sodium_mg     INT,
  storage       VARCHAR(200),         -- 보관 방법
  FOREIGN KEY (product_id) REFERENCES product(product_id) ON DELETE CASCADE
);

-- ---------- 상품 사진 (대표 · 옆모습 · 위에서) ----------
-- 사진 파일은 images/cakes/ 에 이 이름으로 넣으면 화면에 나와요
INSERT INTO product_image (product_id, view_type, image_url, sort_order) VALUES
(1, 'MAIN', '/images/cakes/best1.jpg', 1), (1, 'SIDE', '/images/cakes/1_side.jpg', 2), (1, 'TOP', '/images/cakes/1_top.jpg', 3),
(2, 'MAIN', '/images/cakes/best2.jpg', 1), (2, 'SIDE', '/images/cakes/2_side.jpg', 2), (2, 'TOP', '/images/cakes/2_top.jpg', 3),
(3, 'MAIN', '/images/cakes/best3.jpg', 1), (3, 'SIDE', '/images/cakes/3_side.jpg', 2), (3, 'TOP', '/images/cakes/3_top.jpg', 3),
(4, 'MAIN', '/images/cakes/lunchbox1.jpg', 1), (4, 'SIDE', '/images/cakes/4_side.jpg', 2), (4, 'TOP', '/images/cakes/4_top.jpg', 3),
(5, 'MAIN', '/images/cakes/flower1.jpg', 1), (5, 'SIDE', '/images/cakes/5_side.jpg', 2), (5, 'TOP', '/images/cakes/5_top.jpg', 3);

-- ---------- 원재료·원산지·영양성분 (과제용 예시 값) ----------
INSERT INTO product_info (product_id, ingredients, allergens, serving_basis, kcal, sugar_g, protein_g, fat_g, sat_fat_g, sodium_mg, storage) VALUES
(1, '동물성 생크림|국산 1등급 원유 100%\n밀가루|국산 우리밀\n계란|국산 무항생제 동물복지란\n무염버터|프랑스산\n설탕|국산 비정제 원당\n바닐라빈|마다가스카르산\n캐릭터 장식|수제 앙금·천연 색소', '우유, 계란, 밀', '100g당', 320, 24.0, 5.1, 20.5, 12.8, 110, '냉장(0~5℃) 보관, 픽업 당일 드시는 걸 권장해요'),
(2, '동물성 생크림|국산 1등급 원유 100%\n밀가루|국산 우리밀\n계란|국산 무항생제 동물복지란\n무염버터|프랑스산\n설탕|국산 비정제 원당\n레터링 크림|버터크림·천연 색소', '우유, 계란, 밀', '100g당', 305, 22.5, 4.9, 19.2, 12.0, 105, '냉장(0~5℃) 보관, 픽업 당일 드시는 걸 권장해요'),
(3, '동물성 생크림|국산 1등급 원유 100%\n다크 초콜릿|벨기에산 카카오 54%\n코코아 파우더|네덜란드산\n밀가루|국산 우리밀\n계란|국산 무항생제 동물복지란\n딸기|국산 설향', '우유, 계란, 밀, 대두', '100g당', 365, 27.8, 5.6, 23.4, 14.6, 95, '냉장(0~5℃) 보관, 생딸기가 들어가 당일 섭취를 권장해요'),
(4, '동물성 생크림|국산 1등급 원유 100%\n밀가루|국산 우리밀\n계란|국산 무항생제 동물복지란\n무염버터|프랑스산\n설탕|국산 비정제 원당', '우유, 계란, 밀', '100g당', 298, 21.6, 4.8, 18.7, 11.6, 100, '냉장(0~5℃) 보관, 픽업 당일 드시는 걸 권장해요'),
(5, '앙금|국산 백앙금(흰강낭콩)\n쌀가루|국산 멥쌀\n동물성 생크림|국산 1등급 원유 100%\n설탕|국산 비정제 원당\n꽃 색소|천연 색소(비트·치자·단호박)', '우유', '100g당', 270, 30.2, 4.2, 9.8, 6.1, 60, '냉장(0~5℃) 보관, 앙금 꽃은 상온에 오래 두면 녹아요');

-- ---------- 다른 고객님들의 커스텀 (예시 회원 · 픽업 완료 주문 · 사진 후기) ----------
-- 예시 회원 비밀번호는 모두 1234
INSERT INTO member (login_id, password, name, phone, role) VALUES
('minji', '03ac674216f3e15c761ee1a5e255f067953623c8b388b4459e13f978d7c846f4', '김민지', '010-2222-2222', 'USER'),
('junho', '03ac674216f3e15c761ee1a5e255f067953623c8b388b4459e13f978d7c846f4', '이준호', '010-3333-3333', 'USER'),
('seoyeon', '03ac674216f3e15c761ee1a5e255f067953623c8b388b4459e13f978d7c846f4', '박서연', '010-4444-4444', 'USER');

SET @m1 = (SELECT member_id FROM member WHERE login_id = 'minji');
SET @m2 = (SELECT member_id FROM member WHERE login_id = 'junho');
SET @m3 = (SELECT member_id FROM member WHERE login_id = 'seoyeon');

INSERT INTO orders (member_id, total_price, pickup_date, pickup_time, status) VALUES (@m1, 32000, '2026-11-08', '14:00', 'PICKED_UP');
SET @o = LAST_INSERT_ID();
INSERT INTO order_item (order_id, product_id, options, lettering, quantity, price) VALUES (@o, 1, '1호 (3~4인) / 바닐라 / 파스텔 핑크 / 구슬 테두리', '우리 조카 첫 생일', 1, 32000);
INSERT INTO review (order_id, member_id, product_id, rating, content, image_url) VALUES (@o, @m1, 1, 5, '조카 첫 생일이라 핑크로 했는데 너무 귀여웠어요. 곰돌이 얼굴이 사진이랑 똑같아요!', '/images/reviews/custom1.jpg');

INSERT INTO orders (member_id, total_price, pickup_date, pickup_time, status) VALUES (@m2, 21000, '2026-11-12', '18:00', 'PICKED_UP');
SET @o = LAST_INSERT_ID();
INSERT INTO order_item (order_id, product_id, options, lettering, quantity, price) VALUES (@o, 1, '도시락 (1~2인) / 초코 / 화이트 / 조개 테두리', '수고했어 오늘도', 1, 21000);
INSERT INTO review (order_id, member_id, product_id, rating, content, image_url) VALUES (@o, @m2, 1, 4, '초코 시트로 바꿨더니 단맛이 덜해서 좋았어요. 화이트 크림이 깔끔해요.', '/images/reviews/custom2.jpg');

INSERT INTO orders (member_id, total_price, pickup_date, pickup_time, status) VALUES (@m3, 31000, '2026-11-15', '16:00', 'PICKED_UP');
SET @o = LAST_INSERT_ID();
INSERT INTO order_item (order_id, product_id, options, lettering, quantity, price) VALUES (@o, 2, '1호 (3~4인) / 얼그레이 / 파스텔 민트 / 구슬 테두리', '1000일 축하해 우리', 1, 31000);
INSERT INTO review (order_id, member_id, product_id, rating, content, image_url) VALUES (@o, @m3, 2, 5, '민트 크림에 고양이 그림이 찰떡이에요. 레터링 글씨도 깔끔했어요.', '/images/reviews/custom3.jpg');

INSERT INTO orders (member_id, total_price, pickup_date, pickup_time, status) VALUES (@m1, 33000, '2026-11-20', '12:00', 'PICKED_UP');
SET @o = LAST_INSERT_ID();
INSERT INTO order_item (order_id, product_id, options, lettering, quantity, price) VALUES (@o, 3, '1호 (3~4인) / 초코 / 화이트 / 구슬 테두리', 'Merry Christmas', 1, 33000);
INSERT INTO review (order_id, member_id, product_id, rating, content, image_url) VALUES (@o, @m1, 3, 5, '눈사람이 너무 귀여워서 먹기 아까웠어요. 크리스마스 파티 분위기 최고!', '/images/reviews/custom4.jpg');
