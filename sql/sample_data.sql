-- =========================================================
-- 시연용 예시 데이터 (schema.sql 실행 후 실행)
-- 관리자 계정: admin / admin1234   일반 계정: yeji / 1234
-- ※ 비밀번호는 SHA-256으로 바꾼 값을 저장함 (PasswordUtil.java)
-- =========================================================
USE minecake;

INSERT INTO member (login_id, password, name, phone, role) VALUES
('admin', 'ac9689e2272427085e35b9d3e3e8bed88cb3434828b43b86fc0596cad4c6e270', '관리자', '010-0000-0000', 'ADMIN'),
('yeji',  '03ac674216f3e15c761ee1a5e255f067953623c8b388b4459e13f978d7c846f4', '문예지', '010-1111-1111', 'USER');

INSERT INTO product (type, category, name, price, description, image_url, is_best) VALUES
('CAKE', 'CHARACTER', '리락쿠마 케이크',     21000, '하트 시트 위 곰돌이 캐릭터 케이크', '/images/cakes/best1.jpg', TRUE),
('CAKE', 'LETTERING', '1000일 고양이 케이크', 18000, '기념일 레터링과 고양이 그림',       '/images/cakes/best2.jpg', TRUE),
('CAKE', 'SEASON',    '눈사람 초코 케이크',   22000, '크리스마스 시즌 한정 초코 케이크',   '/images/cakes/best3.jpg', TRUE),
('CAKE', 'LUNCHBOX',  '미니 도시락 케이크',   15000, '1~2인용 도시락 케이크',             '/images/cakes/lunchbox1.jpg', FALSE),
('CAKE', 'FLOWER',    '앙금 플라워 케이크',   32000, '앙금 꽃 장식 케이크',               '/images/cakes/flower1.jpg', FALSE),
('ADDON', NULL, '숫자초',     1000, '0~9 중 선택', '/images/addons/candle.jpg', FALSE),
('ADDON', NULL, '케이크 토퍼', 3000, '문구 토퍼',   '/images/addons/topper.jpg', FALSE),
('ADDON', NULL, '케이크 칼',   500,  '플라스틱 칼', '/images/addons/knife.jpg',  FALSE);

INSERT INTO product_option (option_type, name, extra_price) VALUES
('SIZE', '도시락 (1~2인)', 0), ('SIZE', '1호 (3~4인)', 10000), ('SIZE', '2호 (5~6인)', 20000),
('FLAVOR', '바닐라', 0), ('FLAVOR', '초코', 2000), ('FLAVOR', '얼그레이', 2000),
('CREAM_COLOR', '화이트', 0), ('CREAM_COLOR', '파스텔 핑크', 0), ('CREAM_COLOR', '파스텔 민트', 0),
('DECO', '구슬 테두리', 0), ('DECO', '조개 테두리', 1000);

INSERT INTO banner (eyebrow, title, description, image_url, link_url, sort_order) VALUES
('Handmade Custom Cake', 'MINE CAKE', '세상에 하나뿐인 나만의 케이크를 만들어 보세요', '/images/banner/banner1.jpg', '/cake/list.jsp', 1),
('Christmas Season', '크리스마스 케이크 예약', '12/1 ~ 12/20 사전 예약 시 숫자초 무료 증정', '/images/banner/banner2.jpg', '/cake/list.jsp?category=SEASON', 2),
('AI Recommend', '디자인 고민은 AI에게', '상황과 분위기만 고르면 디자인·문구를 추천해 드려요', '/images/banner/banner3.jpg', '/ai/aiCake.jsp', 3);

INSERT INTO faq (question, answer) VALUES
('주문은 며칠 전까지 해야 하나요?', '픽업일 기준 최소 2일 전까지 주문해 주세요.'),
('레터링 글자 수 제한이 있나요?', '최대 20자까지 가능하며 10자를 넘으면 1,000원이 추가됩니다.'),
('픽업 시간을 바꿀 수 있나요?', '제작 시작 전(접수 상태)까지 1:1 문의로 변경할 수 있어요.');

INSERT INTO notice (title, content) VALUES
('Mine Cake 오픈 안내', 'Mine Cake 온라인 주문이 시작되었습니다.'),
('크리스마스 시즌 예약 안내', '12/24~25 픽업 주문은 12/20까지 받습니다.');

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
