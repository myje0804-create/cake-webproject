-- =========================================================
-- Mine Cake DB 테이블 생성
-- MySQL Workbench에서 이 파일을 열고 전체 실행(⚡)
-- =========================================================
CREATE DATABASE IF NOT EXISTS minecake DEFAULT CHARACTER SET utf8mb4;
USE minecake;

-- 회원
CREATE TABLE member (
  member_id   INT AUTO_INCREMENT PRIMARY KEY,
  login_id    VARCHAR(30)  NOT NULL UNIQUE,
  password    VARCHAR(255) NOT NULL,
  name        VARCHAR(30)  NOT NULL,
  phone       VARCHAR(20),
  email       VARCHAR(100),
  role        VARCHAR(10)  NOT NULL DEFAULT 'USER',      -- USER / ADMIN
  created_at  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- 상품 (케이크 + 추가상품)
CREATE TABLE product (
  product_id   INT AUTO_INCREMENT PRIMARY KEY,
  type         VARCHAR(10)  NOT NULL DEFAULT 'CAKE',     -- CAKE / ADDON
  category     VARCHAR(20),                              -- LETTERING / CHARACTER / LUNCHBOX / FLOWER / SEASON
  name         VARCHAR(50)  NOT NULL,
  price        INT          NOT NULL,                    -- 시작 가격
  description  TEXT,
  image_url    VARCHAR(255),
  is_best      BOOLEAN      NOT NULL DEFAULT FALSE,      -- 메인 Best Design 노출
  created_at   DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- 커스텀 옵션
CREATE TABLE product_option (
  option_id    INT AUTO_INCREMENT PRIMARY KEY,
  option_type  VARCHAR(20) NOT NULL,                     -- SIZE / FLAVOR / CREAM_COLOR / DECO
  name         VARCHAR(30) NOT NULL,
  extra_price  INT         NOT NULL DEFAULT 0
);

-- 장바구니
CREATE TABLE cart (
  cart_id     INT AUTO_INCREMENT PRIMARY KEY,
  member_id   INT NOT NULL,
  product_id  INT NOT NULL,
  options     VARCHAR(255),                              -- 선택 옵션 요약
  lettering   VARCHAR(40),
  request     VARCHAR(255),
  quantity    INT NOT NULL DEFAULT 1,
  price       INT NOT NULL,                              -- 옵션 포함 1개 가격
  FOREIGN KEY (member_id)  REFERENCES member(member_id)  ON DELETE CASCADE,
  FOREIGN KEY (product_id) REFERENCES product(product_id) ON DELETE CASCADE
);

-- 주문
CREATE TABLE orders (
  order_id     INT AUTO_INCREMENT PRIMARY KEY,
  member_id    INT NOT NULL,
  total_price  INT NOT NULL,
  pickup_date  DATE NOT NULL,
  pickup_time  TIME NOT NULL,
  status       VARCHAR(20) NOT NULL DEFAULT 'RECEIVED',  -- RECEIVED(접수) / MAKING(제작 중) / READY(픽업 준비 완료) / PICKED_UP(픽업 완료)
  ordered_at   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (member_id) REFERENCES member(member_id)
);

-- 주문 상세
CREATE TABLE order_item (
  order_item_id  INT AUTO_INCREMENT PRIMARY KEY,
  order_id       INT NOT NULL,
  product_id     INT NOT NULL,
  options        VARCHAR(255),
  lettering      VARCHAR(40),
  request        VARCHAR(255),
  quantity       INT NOT NULL DEFAULT 1,
  price          INT NOT NULL,
  FOREIGN KEY (order_id)   REFERENCES orders(order_id) ON DELETE CASCADE,
  FOREIGN KEY (product_id) REFERENCES product(product_id)
);

-- 후기 (픽업 완료 주문만 작성)
CREATE TABLE review (
  review_id   INT AUTO_INCREMENT PRIMARY KEY,
  order_id    INT NOT NULL,
  member_id   INT NOT NULL,
  product_id  INT NOT NULL,
  rating      TINYINT NOT NULL CHECK (rating BETWEEN 1 AND 5),
  content     TEXT,
  image_url   VARCHAR(255),
  is_hidden   BOOLEAN NOT NULL DEFAULT FALSE,
  created_at  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (order_id)   REFERENCES orders(order_id),
  FOREIGN KEY (member_id)  REFERENCES member(member_id),
  FOREIGN KEY (product_id) REFERENCES product(product_id)
);

-- 고객센터
CREATE TABLE notice (
  notice_id   INT AUTO_INCREMENT PRIMARY KEY,
  title       VARCHAR(100) NOT NULL,
  content     TEXT,
  created_at  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE faq (
  faq_id    INT AUTO_INCREMENT PRIMARY KEY,
  question  VARCHAR(200) NOT NULL,
  answer    TEXT NOT NULL
);

CREATE TABLE inquiry (
  inquiry_id  INT AUTO_INCREMENT PRIMARY KEY,
  member_id   INT NOT NULL,
  title       VARCHAR(100) NOT NULL,
  content     TEXT,
  answer      TEXT,
  created_at  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (member_id) REFERENCES member(member_id)
);

-- 메인 배너
CREATE TABLE banner (
  banner_id    INT AUTO_INCREMENT PRIMARY KEY,
  eyebrow      VARCHAR(50),
  title        VARCHAR(50) NOT NULL,
  description  VARCHAR(200),
  image_url    VARCHAR(255),
  link_url     VARCHAR(255),
  sort_order   INT NOT NULL DEFAULT 0
);
