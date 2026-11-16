-- =========================================================
-- 시연용 예시 데이터 (schema.sql 실행 후 실행)
-- 관리자 계정: admin / admin1234   일반 계정: yeji / 1234
-- ※ 비밀번호 암호화를 붙이면 이 값도 바꿔야 함
-- =========================================================
USE minecake;

INSERT INTO member (login_id, password, name, phone, role) VALUES
('admin', 'admin1234', '관리자', '010-0000-0000', 'ADMIN'),
('yeji',  '1234',      '문예지', '010-1111-1111', 'USER');

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
