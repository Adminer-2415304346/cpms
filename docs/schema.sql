-- ============================================
-- CPMS 社区物业管理系统 - 数据库建库脚本
-- DBMS: MySQL 8.0+
-- ============================================

-- 1. 创建数据库
DROP DATABASE IF EXISTS cpms;
CREATE DATABASE cpms
    DEFAULT CHARACTER SET utf8mb4
    DEFAULT COLLATE utf8mb4_unicode_ci;

USE cpms;

-- 2. 创建用户并授权
DROP USER IF EXISTS 'cpms_admin'@'localhost';
CREATE USER 'cpms_admin'@'localhost' IDENTIFIED BY 'cpms2026@Secure';
GRANT SELECT, INSERT, UPDATE, DELETE ON cpms.* TO 'cpms_admin'@'localhost';
FLUSH PRIVILEGES;

-- ============================================
-- 3. 建表
-- ============================================

-- 3.1 用户表
CREATE TABLE user (
    user_id       BIGINT AUTO_INCREMENT PRIMARY KEY,
    username      VARCHAR(50)  NOT NULL UNIQUE,
    password      VARCHAR(255) NOT NULL,
    role          ENUM('admin','staff','owner') NOT NULL,
    real_name     VARCHAR(50),
    phone         VARCHAR(20),
    email         VARCHAR(100),
    status        ENUM('active','disabled') DEFAULT 'active',
    created_at    DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- 3.2 业主表（继承用户）
CREATE TABLE owner (
    owner_id      BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id       BIGINT       NOT NULL UNIQUE,
    name          VARCHAR(50)  NOT NULL,
    id_card       VARCHAR(18)  NOT NULL UNIQUE,
    phone         VARCHAR(20),
    move_in_date  DATE,
    FOREIGN KEY (user_id) REFERENCES user(user_id)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

-- 3.3 楼栋表
CREATE TABLE building (
    building_id   BIGINT AUTO_INCREMENT PRIMARY KEY,
    building_name VARCHAR(100) NOT NULL,
    floors        INT,
    description   TEXT
) ENGINE=InnoDB;

-- 3.4 房间表
CREATE TABLE room (
    room_id       BIGINT AUTO_INCREMENT PRIMARY KEY,
    building_id   BIGINT       NOT NULL,
    unit_name     VARCHAR(50),
    room_number   VARCHAR(20)  NOT NULL,
    area          DECIMAL(10,2),
    room_type     VARCHAR(50),
    status        ENUM('vacant','occupied','maintenance') DEFAULT 'vacant',
    FOREIGN KEY (building_id) REFERENCES building(building_id)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

-- 3.5 业主-房间关联表（M:N 中间表）
CREATE TABLE owner_room (
    id            BIGINT AUTO_INCREMENT PRIMARY KEY,
    owner_id      BIGINT       NOT NULL,
    room_id       BIGINT       NOT NULL,
    relation_type ENUM('owner','tenant') DEFAULT 'owner',
    start_date    DATE,
    end_date      DATE,
    FOREIGN KEY (owner_id) REFERENCES owner(owner_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (room_id) REFERENCES room(room_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    UNIQUE KEY uk_owner_room (owner_id, room_id)
) ENGINE=InnoDB;

-- 3.6 账单表
CREATE TABLE bill (
    bill_id       BIGINT AUTO_INCREMENT PRIMARY KEY,
    room_id       BIGINT       NOT NULL,
    fee_type      VARCHAR(50)  NOT NULL,
    amount        DECIMAL(10,2) NOT NULL,
    period        VARCHAR(20),
    due_date      DATE,
    status        ENUM('unpaid','paid','overdue') DEFAULT 'unpaid',
    created_at    DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (room_id) REFERENCES room(room_id)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

-- 3.7 缴费记录表
CREATE TABLE payment (
    payment_id    BIGINT AUTO_INCREMENT PRIMARY KEY,
    bill_id       BIGINT       NOT NULL,
    amount        DECIMAL(10,2) NOT NULL,
    pay_method    VARCHAR(20),
    pay_time      DATETIME DEFAULT CURRENT_TIMESTAMP,
    staff_id      BIGINT,
    FOREIGN KEY (bill_id) REFERENCES bill(bill_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (staff_id) REFERENCES user(user_id)
        ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB;

-- 3.8 报修表
CREATE TABLE repair (
    repair_id     BIGINT AUTO_INCREMENT PRIMARY KEY,
    owner_id      BIGINT       NOT NULL,
    room_id       BIGINT       NOT NULL,
    description   TEXT         NOT NULL,
    urgency       ENUM('low','medium','high') DEFAULT 'low',
    status        ENUM('pending','assigned','in_progress','completed','confirmed') DEFAULT 'pending',
    staff_id      BIGINT,
    created_at    DATETIME DEFAULT CURRENT_TIMESTAMP,
    completed_at  DATETIME,
    FOREIGN KEY (owner_id) REFERENCES owner(owner_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (room_id) REFERENCES room(room_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (staff_id) REFERENCES user(user_id)
        ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB;

-- 3.9 投诉建议表
CREATE TABLE complaint (
    complaint_id  BIGINT AUTO_INCREMENT PRIMARY KEY,
    owner_id      BIGINT       NOT NULL,
    type          ENUM('complaint','suggestion') NOT NULL,
    content       TEXT         NOT NULL,
    is_anonymous  TINYINT(1)   DEFAULT 0,
    status        ENUM('pending','processing','resolved') DEFAULT 'pending',
    reply         TEXT,
    created_at    DATETIME DEFAULT CURRENT_TIMESTAMP,
    replied_at    DATETIME,
    FOREIGN KEY (owner_id) REFERENCES owner(owner_id)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

-- 3.10 公告表
CREATE TABLE announcement (
    announcement_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    title         VARCHAR(200) NOT NULL,
    content       TEXT,
    publisher_id  BIGINT       NOT NULL,
    publish_time  DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (publisher_id) REFERENCES user(user_id)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

-- 3.11 停车位表
CREATE TABLE parking_spot (
    spot_id       BIGINT AUTO_INCREMENT PRIMARY KEY,
    spot_code     VARCHAR(50)  NOT NULL UNIQUE,
    location      VARCHAR(200),
    type          VARCHAR(50),
    status        ENUM('available','occupied','maintenance') DEFAULT 'available'
) ENGINE=InnoDB;

-- 3.12 车辆表
CREATE TABLE vehicle (
    vehicle_id    BIGINT AUTO_INCREMENT PRIMARY KEY,
    owner_id      BIGINT       NOT NULL,
    spot_id       BIGINT,
    plate_number  VARCHAR(20)  NOT NULL UNIQUE,
    vehicle_type  VARCHAR(50),
    color         VARCHAR(20),
    FOREIGN KEY (owner_id) REFERENCES owner(owner_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (spot_id) REFERENCES parking_spot(spot_id)
        ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB;

-- ============================================
-- 4. 索引（加速查询）
-- ============================================

-- 用户登录加速
CREATE INDEX idx_user_username ON user(username);
CREATE INDEX idx_user_role ON user(role);

-- 房间查询加速
CREATE INDEX idx_room_building ON room(building_id);
CREATE INDEX idx_room_status ON room(status);

-- 账单查询加速（欠费催缴常用）
CREATE INDEX idx_bill_room ON bill(room_id);
CREATE INDEX idx_bill_status ON bill(status);
CREATE INDEX idx_bill_due_date ON bill(due_date);

-- 缴费记录查询
CREATE INDEX idx_payment_bill ON payment(bill_id);

-- 报修工单查询加速
CREATE INDEX idx_repair_owner ON repair(owner_id);
CREATE INDEX idx_repair_status ON repair(status);
CREATE INDEX idx_repair_staff ON repair(staff_id);

-- 投诉查询加速
CREATE INDEX idx_complaint_owner ON complaint(owner_id);
CREATE INDEX idx_complaint_status ON complaint(status);

-- 车辆查询加速
CREATE INDEX idx_vehicle_owner ON vehicle(owner_id);
CREATE INDEX idx_vehicle_spot ON vehicle(spot_id);

-- ============================================
-- 5. 视图（欠费催缴一览）
-- ============================================

CREATE VIEW v_overdue_bills AS
SELECT
    b.bill_id,
    o.name          AS owner_name,
    o.phone         AS owner_phone,
    bu.building_name,
    r.unit_name,
    r.room_number,
    b.fee_type,
    b.amount,
    b.period,
    b.due_date,
    b.status,
    DATEDIFF(CURDATE(), b.due_date) AS overdue_days
FROM bill b
JOIN room r        ON b.room_id = r.room_id
JOIN building bu   ON r.building_id = bu.building_id
JOIN owner_room owr ON r.room_id = owr.room_id
JOIN owner o        ON owr.owner_id = o.owner_id
WHERE b.status IN ('unpaid', 'overdue')
ORDER BY b.due_date ASC;

-- ============================================
-- 6. 触发器（缴费后自动更新账单状态）
-- ============================================

DELIMITER //

CREATE TRIGGER tr_payment_after_insert
AFTER INSERT ON payment
FOR EACH ROW
BEGIN
    UPDATE bill
    SET status = 'paid'
    WHERE bill_id = NEW.bill_id;
END//

DELIMITER ;

-- ============================================
-- 7. 示例数据
-- ============================================

-- ============================================
-- 7.1 用户（密码均为 123456 的 MD5）
--   演示账号: admin_super / staff_zhang / owner_wang
-- ============================================

-- 管理员（1人）
INSERT INTO user (username, password, role, real_name, phone, email) VALUES
('admin_super', 'e10adc3949ba59abbe56e057f20f883e', 'admin', '系统管理员', '13800000001', 'admin@cpms.com');

-- 物业人员（4人）
INSERT INTO user (username, password, role, real_name, phone, email) VALUES
('staff_zhang', 'e10adc3949ba59abbe56e057f20f883e', 'staff', '张建国', '13800000002', 'zhang@cpms.com'),
('staff_li',   'e10adc3949ba59abbe56e057f20f883e', 'staff', '李明华', '13800000003', 'li@cpms.com'),
('staff_wang', 'e10adc3949ba59abbe56e057f20f883e', 'staff', '王丽娟', '13800000004', 'wangj@cpms.com'),
('staff_chen', 'e10adc3949ba59abbe56e057f20f883e', 'staff', '陈志强', '13800000005', 'chen@cpms.com');

-- 业主用户（15人，含演示账号 owner_wang）
INSERT INTO user (username, password, role, real_name, phone, email) VALUES
('owner_wang',  'e10adc3949ba59abbe56e057f20f883e', 'owner', '王建国', '13900000001', 'wang@cpms.com'),
('owner_zhao',  'e10adc3949ba59abbe56e057f20f883e', 'owner', '赵丽华', '13900000002', 'zhao@cpms.com'),
('owner_sun',   'e10adc3949ba59abbe56e057f20f883e', 'owner', '孙明辉', '13900000003', 'sun@cpms.com'),
('owner_liu',   'e10adc3949ba59abbe56e057f20f883e', 'owner', '刘志强', '13900000004', 'liu@cpms.com'),
('owner_zhou',  'e10adc3949ba59abbe56e057f20f883e', 'owner', '周美玲', '13900000005', 'zhou@cpms.com'),
('owner_wu',    'e10adc3949ba59abbe56e057f20f883e', 'owner', '吴德军', '13900000006', 'wu@cpms.com'),
('owner_zheng', 'e10adc3949ba59abbe56e057f20f883e', 'owner', '郑伟',   '13900000007', 'zheng@cpms.com'),
('owner_huang', 'e10adc3949ba59abbe56e057f20f883e', 'owner', '黄秀英', '13900000008', 'huang@cpms.com'),
('owner_xu',    'e10adc3949ba59abbe56e057f20f883e', 'owner', '徐文博', '13900000009', 'xu@cpms.com'),
('owner_ma',    'e10adc3949ba59abbe56e057f20f883e', 'owner', '马海燕', '13900000010', 'ma@cpms.com'),
('owner_lin',   'e10adc3949ba59abbe56e057f20f883e', 'owner', '林俊杰', '13900000011', 'lin@cpms.com'),
('owner_he',    'e10adc3949ba59abbe56e057f20f883e', 'owner', '何雪梅', '13900000012', 'he@cpms.com'),
('owner_gao',   'e10adc3949ba59abbe56e057f20f883e', 'owner', '高天明', '13900000013', 'gao@cpms.com'),
('owner_yang',  'e10adc3949ba59abbe56e057f20f883e', 'owner', '杨志远', '13900000014', 'yang@cpms.com'),
('owner_chen',  'e10adc3949ba59abbe56e057f20f883e', 'owner', '陈小芳', '13900000015', 'chenx@cpms.com');

-- ============================================
-- 7.2 业主档案
-- ============================================
INSERT INTO owner (user_id, name, id_card, phone, move_in_date) VALUES
(6,  '王建国', '410105198503121234', '13900000001', '2023-06-15'),
(7,  '赵丽华', '410105197809085678', '13900000002', '2022-03-20'),
(8,  '孙明辉', '410105199011209012', '13900000003', '2024-01-10'),
(9,  '刘志强', '410105198207153456', '13900000004', '2022-09-01'),
(10, '周美玲', '410105199306227890', '13900000005', '2023-12-05'),
(11, '吴德军', '410105197512011234', '13900000006', '2021-08-18'),
(12, '郑伟',   '410105198808085678', '13900000007', '2023-04-22'),
(13, '黄秀英', '410105196910309012', '13900000008', '2020-11-30'),
(14, '徐文博', '410105199505183456', '13900000009', '2024-07-08'),
(15, '马海燕', '410105198106207890', '13900000010', '2021-05-12'),
(16, '林俊杰', '410105199208251234', '13900000011', '2023-02-14'),
(17, '何雪梅', '410105197703115678', '13900000012', '2021-10-28'),
(18, '高天明', '410105198907079012', '13900000013', '2023-08-06'),
(19, '杨志远', '410105198412191234', '13900000014', '2022-06-30'),
(20, '陈小芳', '410105199610085678', '13900000015', '2024-03-17');

-- ============================================
-- 7.3 楼栋
-- ============================================
INSERT INTO building (building_name, floors, description) VALUES
('1号楼', 18, '高层住宅，2梯4户，2021年交付'),
('2号楼', 12, '小高层住宅，1梯2户，2020年交付'),
('3号楼', 18, '高层住宅，2梯4户，2021年交付'),
('5号楼',  6, '花园洋房，1梯2户，带电梯，2022年交付'),
('8号楼', 11, '中高层住宅，2梯3户，2021年交付');

-- ============================================
-- 7.4 房间
-- ============================================

-- 1号楼（18层，2梯4户）— 1单元 / 2单元
INSERT INTO room (building_id, unit_name, room_number, area, room_type, status) VALUES
-- 1单元
(1, '1单元', '101', 120.50, '三室两厅', 'occupied'),
(1, '1单元', '102', 120.50, '三室两厅', 'occupied'),
(1, '1单元', '501', 120.50, '三室两厅', 'occupied'),
(1, '1单元', '502', 120.50, '三室两厅', 'occupied'),
(1, '1单元', '1201',120.50, '三室两厅', 'vacant'),
(1, '1单元', '1501',120.50, '三室两厅', 'occupied'),
(1, '1单元', '1801',120.50, '三室两厅', 'occupied'),
(1, '1单元', '1802',120.50, '三室两厅', 'vacant'),
-- 2单元
(1, '2单元', '201',  89.00, '两室一厅', 'occupied'),
(1, '2单元', '202',  89.00, '两室一厅', 'occupied'),
(1, '2单元', '801',  89.00, '两室一厅', 'maintenance'),
(1, '2单元', '902',  89.00, '两室一厅', 'occupied'),
(1, '2单元', '1402', 89.00, '两室一厅', 'occupied'),
(1, '2单元', '1701', 89.00, '两室一厅', 'vacant');

-- 2号楼（12层，1梯2户）— 1单元 / 2单元
INSERT INTO room (building_id, unit_name, room_number, area, room_type, status) VALUES
-- 1单元
(2, '1单元', '101', 140.00, '四室两厅', 'occupied'),
(2, '1单元', '102', 140.00, '四室两厅', 'occupied'),
(2, '1单元', '501', 140.00, '四室两厅', 'vacant'),
(2, '1单元', '602', 140.00, '四室两厅', 'vacant'),
(2, '1单元', '1001',140.00, '四室两厅', 'occupied'),
(2, '1单元', '1201',140.00, '四室两厅', 'occupied'),
-- 2单元
(2, '2单元', '301', 110.00, '三室两厅', 'occupied'),
(2, '2单元', '302', 110.00, '三室两厅', 'occupied'),
(2, '2单元', '802', 110.00, '三室两厅', 'occupied'),
(2, '2单元', '902', 110.00, '三室两厅', 'vacant');

-- 3号楼（18层，2梯4户）— 1单元 / 2单元
INSERT INTO room (building_id, unit_name, room_number, area, room_type, status) VALUES
-- 1单元
(3, '1单元', '101',  85.00, '两室一厅', 'occupied'),
(3, '1单元', '102',  85.00, '两室一厅', 'occupied'),
(3, '1单元', '601',  85.00, '两室一厅', 'occupied'),
(3, '1单元', '702',  85.00, '两室一厅', 'vacant'),
(3, '1单元', '1301', 85.00, '两室一厅', 'occupied'),
(3, '1单元', '1601', 85.00, '两室一厅', 'occupied'),
(3, '1单元', '1602', 85.00, '两室一厅', 'occupied'),
-- 2单元
(3, '2单元', '401', 115.00, '三室两厅', 'occupied'),
(3, '2单元', '502', 115.00, '三室两厅', 'vacant'),
(3, '2单元', '1001',115.00, '三室两厅', 'occupied'),
(3, '2单元', '1402',115.00, '三室两厅', 'occupied'),
(3, '2单元', '1801',115.00, '三室两厅', 'occupied');

-- 5号楼（6层，1梯2户 — 花园洋房）
INSERT INTO room (building_id, unit_name, room_number, area, room_type, status) VALUES
(4, '1单元', '101', 160.00, '四室两厅',     'occupied'),
(4, '1单元', '102', 160.00, '四室两厅',     'occupied'),
(4, '1单元', '301', 160.00, '四室两厅',     'vacant'),
(4, '1单元', '501', 160.00, '四室两厅',     'occupied'),
(4, '1单元', '601', 200.00, '四室两厅复式', 'occupied'),
(4, '1单元', '602', 200.00, '四室两厅复式', 'vacant');

-- 8号楼（11层，2梯3户）— 1单元
INSERT INTO room (building_id, unit_name, room_number, area, room_type, status) VALUES
(5, '1单元', '101', 105.00, '三室两厅', 'occupied'),
(5, '1单元', '102',  78.00, '两室一厅', 'occupied'),
(5, '1单元', '201', 105.00, '三室两厅', 'occupied'),
(5, '1单元', '202',  78.00, '两室一厅', 'vacant'),
(5, '1单元', '701', 105.00, '三室两厅', 'occupied'),
(5, '1单元', '702',  78.00, '两室一厅', 'occupied'),
(5, '1单元', '1001',105.00, '三室两厅', 'occupied'),
(5, '1单元', '1102', 78.00, '两室一厅', 'vacant');

-- ============================================
-- 7.5 业主-房间关联
-- ============================================
INSERT INTO owner_room (owner_id, room_id, relation_type, start_date) VALUES
-- 王建国：1-1-101（自住）+ 1-2-201（出租）
(1,  1, 'owner',  '2023-06-15'),
(1,  9, 'owner',  '2023-06-15'),
-- 赵丽华：1-1-102（自住）
(2,  2, 'owner',  '2022-03-20'),
-- 孙明辉：1-1-501（自住）+ 2-1-501（投资）
(3,  3, 'owner',  '2024-01-10'),
(3, 17, 'owner',  '2024-01-10'),
-- 刘志强：1-1-502（自住）
(4,  4, 'owner',  '2022-09-01'),
-- 周美玲：1-1-1501（自住）
(5,  6, 'owner',  '2023-12-05'),
-- 吴德军：1-2-202 + 1-2-902（一套自住一套给父母）
(6, 10, 'owner',  '2021-08-18'),
(6, 12, 'owner',  '2021-08-18'),
-- 郑伟：1-2-1402（自住）
(7, 13, 'owner',  '2023-04-22'),
-- 黄秀英：2-1-101 + 2-1-102（自住+儿子婚房）
(8, 15, 'owner',  '2020-11-30'),
(8, 16, 'owner',  '2020-11-30'),
-- 徐文博：2-1-1001（自住）
(9, 19, 'owner',  '2024-07-08'),
-- 马海燕：2-1-1201（自住）
(10, 20, 'owner', '2021-05-12'),
-- 林俊杰：2-2-301（自住）
(11, 21, 'owner', '2023-02-14'),
-- 何雪梅：2-2-302 + 2-2-802（自住+投资）
(12, 22, 'owner', '2021-10-28'),
(12, 23, 'owner', '2021-10-28'),
-- 高天明：3-1-101（自住）
(13, 25, 'owner', '2023-08-06'),
-- 杨志远：3-1-102 + 3-2-401（自住+出租）
(14, 26, 'owner', '2022-06-30'),
(14, 32, 'owner', '2022-06-30'),
-- 陈小芳：3-1-601（租住）
(15, 27, 'tenant', '2024-03-17');

-- ============================================
-- 7.6 停车位
-- ============================================
INSERT INTO parking_spot (spot_code, location, type, status) VALUES
('A001', '地下一层A区', '标准',   'occupied'),
('A002', '地下一层A区', '标准',   'available'),
('A003', '地下一层A区', '标准',   'occupied'),
('A004', '地下一层A区', '标准',   'available'),
('A005', '地下一层A区', '充电桩', 'occupied'),
('A006', '地下一层A区', '标准',   'maintenance'),
('B001', '地下一层B区', '大型',   'available'),
('B002', '地下一层B区', '大型',   'occupied'),
('B003', '地下一层B区', '大型',   'available'),
('B004', '地下一层B区', '子母',   'occupied'),
('B005', '地下一层B区', '子母',   'available'),
('C001', '地下二层C区', '标准',   'available'),
('C002', '地下二层C区', '标准',   'available'),
('C003', '地下二层C区', '标准',   'occupied'),
('C004', '地下二层C区', '充电桩', 'available'),
('C005', '地下二层C区', '充电桩', 'maintenance'),
('C006', '地下二层C区', '微型',   'available'),
('D001', '地面来访区',   '临时',   'available'),
('D002', '地面来访区',   '临时',   'available'),
('D003', '地面来访区',   '临时',   'maintenance');

-- ============================================
-- 7.7 车辆
-- ============================================
INSERT INTO vehicle (owner_id, spot_id, plate_number, vehicle_type, color) VALUES
(1,   1,  '豫A88888', '轿车',     '黑色'),
(1,  NULL, '豫AD12345', '轿车',   '白色'),
(2,   3,  '豫AF66888', 'SUV',     '白色'),
(4,   5,  '豫AN16888', '新能源',  '蓝色'),
(6,   8,  '豫A12345',  '轿车',    '白色'),
(7,  14,  '豫AB66666', 'SUV',    '银色'),
(8,  10,  '豫A67890',  '轿车',    '黑色'),
(9,  NULL, '豫AF88899', 'SUV',   '黑色'),
(10, NULL, '豫AD00001', '新能源', '白色'),
(13,  4,  '豫AG55555', '轿车',    '红色'),
(14, NULL, '豫AV12345', '面包车', '银色'),
(11,  2,  '豫AE33333', 'SUV',    '深灰');

-- ============================================
-- 7.8 账单
-- ============================================
INSERT INTO bill (room_id, fee_type, amount, period, due_date, status) VALUES
-- 1-1-101 王建国（已缴+未缴）
(1, '物业费', 2410.00, '2026-Q1', '2026-03-31', 'paid'),
(1, '物业费', 2410.00, '2026-Q2', '2026-06-30', 'unpaid'),
(1, '水费',    156.30, '2026-03',   '2026-04-15', 'paid'),
(1, '电费',    328.50, '2026-03',   '2026-04-15', 'paid'),
(1, '水费',    142.80, '2026-04',   '2026-05-15', 'unpaid'),
-- 1-1-102 赵丽华（部分欠费）
(2, '物业费', 2410.00, '2026-Q1', '2026-03-31', 'paid'),
(2, '物业费', 2410.00, '2026-Q2', '2026-06-30', 'unpaid'),
(2, '电费',    412.00, '2026-04',   '2026-05-15', 'unpaid'),
-- 1-1-501 孙明辉
(3, '物业费', 2410.00, '2026-Q1', '2026-03-31', 'paid'),
(3, '物业费', 2410.00, '2026-Q2', '2026-06-30', 'unpaid'),
-- 1-1-502 刘志强
(4, '物业费', 2410.00, '2026-Q1', '2026-03-31', 'overdue'),
(4, '物业费', 2410.00, '2026-Q2', '2026-06-30', 'unpaid'),
-- 1-2-201 王建国出租房
(9, '物业费', 1780.00, '2026-Q1', '2026-03-31', 'paid'),
(9, '物业费', 1780.00, '2026-Q2', '2026-06-30', 'unpaid'),
-- 1-2-202 吴德军
(10, '物业费', 1780.00, '2026-Q1', '2026-03-31', 'paid'),
(10, '物业费', 1780.00, '2026-Q2', '2026-06-30', 'unpaid'),
(10, '停车费',  800.00, '2026-Q2', '2026-06-30', 'unpaid'),
-- 2-1-101 黄秀英
(15, '物业费', 2800.00, '2026-Q1', '2026-03-31', 'paid'),
(15, '物业费', 2800.00, '2026-Q2', '2026-06-30', 'unpaid'),
(15, '燃气费',  203.40, '2026-03',   '2026-04-20', 'paid'),
-- 2-2-301 林俊杰
(21, '物业费', 2200.00, '2026-Q1', '2026-03-31', 'overdue'),
(21, '物业费', 2200.00, '2026-Q2', '2026-06-30', 'unpaid'),
(21, '水费',    189.60, '2026-04',   '2026-05-15', 'unpaid'),
-- 3-1-101 高天明
(25, '物业费', 1700.00, '2026-Q1', '2026-03-31', 'paid'),
(25, '物业费', 1700.00, '2026-Q2', '2026-06-30', 'unpaid'),
-- 5-1-601 顶层复式（未关联到具体 owner）
(41, '物业费', 4000.00, '2026-Q1', '2026-03-31', 'paid'),
(41, '物业费', 4000.00, '2026-Q2', '2026-06-30', 'unpaid'),
(41, '电费',    567.20, '2026-04',   '2026-05-15', 'unpaid');

-- ============================================
-- 7.9 缴费记录
-- ============================================
INSERT INTO payment (bill_id, amount, pay_method, staff_id) VALUES
(1,  2410.00, '微信支付', 2),
(6,  2410.00, '支付宝',   3),
(9,  2410.00, '微信支付', 2),
(13, 1780.00, '银行卡',   4),
(15, 1780.00, '微信支付', 2),
(18, 2800.00, '现金',     5),
(20,  203.40, '微信支付', 3),
(24, 1700.00, '支付宝',   4),
(26, 4000.00, '银行卡',   2);

-- ============================================
-- 7.10 报修工单
-- ============================================
INSERT INTO repair (owner_id, room_id, description, urgency, status, staff_id, created_at, completed_at) VALUES
(1,   1,  '卫生间水管漏水，地面有积水',                            'high',   'completed',   2, '2026-04-10 09:30:00', '2026-04-10 14:00:00'),
(1,   9,  '厨房下水管道反味严重',                                  'medium', 'in_progress', 3, '2026-05-08 10:15:00', NULL),
(2,   2,  '客厅空调不制冷，夏季将至急需维修',                       'medium', 'assigned',    4, '2026-05-12 08:40:00', NULL),
(4,   4,  '入户门锁芯损坏，无法正常开锁',                           'high',   'completed',   2, '2026-04-22 16:00:00', '2026-04-22 18:30:00'),
(6,  10,  '阳台推拉门轨道变形，推拉困难',                           'low',    'pending',     NULL, '2026-05-15 07:50:00', NULL),
(8,  15,  '楼顶渗水导致天花板有水渍',                               'medium', 'in_progress', 5, '2026-05-03 11:20:00', NULL),
(11, 21,  '房间墙插没电，可能线路松动',                             'medium', 'assigned',    3, '2026-05-14 14:10:00', NULL),
(12, 22,  '卫生间浴霸不制热',                                       'low',    'pending',     NULL, '2026-05-18 09:00:00', NULL),
(13, 25,  '走廊声控灯损坏，夜晚出入不便',                           'low',    'completed',   4, '2026-05-02 19:30:00', '2026-05-03 10:00:00'),
(14, 26,  '地暖分水器接口渗水，地板局部鼓起',                       'high',   'in_progress', 2, '2026-05-16 08:00:00', NULL);

-- ============================================
-- 7.11 投诉建议
-- ============================================
INSERT INTO complaint (owner_id, type, content, is_anonymous, status, reply, created_at, replied_at) VALUES
(3,  'complaint',  '夜间电梯运行噪音过大，尤其凌晨时段影响休息，希望加装隔音措施',            0, 'pending',    NULL,                                                                                '2026-05-10 22:30:00', NULL),
(5,  'complaint',  '小区门口共享单车乱停乱放，影响业主出行，请物业协调清理',                    0, 'processing', NULL,                                                                                '2026-05-08 08:15:00', NULL),
(7,  'suggestion', '建议在小区内增设儿童游乐设施，目前小区学龄前儿童较多，现有设施不够用',      0, 'resolved',   '感谢您的建议，物业已向业委会反馈，将在今年第三季度规划新增儿童滑梯和跷跷板。',   '2026-04-20 14:00:00', '2026-04-22 09:30:00'),
(8,  'complaint',  '2号楼楼下垃圾桶经常溢出未及时清运，夏季蚊虫滋生严重',                       0, 'resolved',   '非常抱歉给您带来不便，已增加清运频次至每日两次，并增设两组垃圾桶。',             '2026-04-15 07:40:00', '2026-04-16 11:00:00'),
(9,  'complaint',  '楼上住户经常深夜拖拽家具发出噪音，沟通无果，请物业协调',                    0, 'processing', NULL,                                                                                '2026-05-13 23:15:00', NULL),
(10, 'suggestion', '建议地下车库增加引导标识，目前B区C区容易迷路，访客尤其不方便',                0, 'pending',    NULL,                                                                                '2026-05-17 16:20:00', NULL),
(15, 'complaint',  '小区绿化带内有人遛狗不拴绳，存在安全隐患',                                   1, 'processing', '已安排安保人员加强巡查，对违规遛狗业主进行劝导并张贴文明养犬提示。',             '2026-05-11 18:45:00', '2026-05-12 14:00:00'),
(12, 'complaint',  '3号楼下快递柜频繁故障，取件不便，要求检修或更换',                            0, 'pending',    NULL,                                                                                '2026-05-18 10:30:00', NULL);

-- ============================================
-- 7.12 公告
-- ============================================
INSERT INTO announcement (title, content, publisher_id, publish_time) VALUES
('关于小区停水通知',
 '因市政管道维修，5月20日（周三）8:00至18:00全小区将停水，请各位业主提前储水备用。恢复供水后可能出现短暂水质浑浊，请适当排放后使用。',
 2, '2026-05-15 09:00:00'),

('关于缴纳2026年第二季度物业费的通知',
 '尊敬的各位业主：2026年第二季度（4月-6月）物业费已开始收取，请于2026年6月30日前通过物业前台、微信或支付宝完成缴纳。逾期将产生滞纳金，感谢您的配合！',
 2, '2026-04-01 08:00:00'),

('关于开展小区消防安全演练的通知',
 '为增强业主消防安全意识，物业定于5月25日（周一）上午10:00在小区中心广场开展消防演练，现场教授灭火器使用、逃生技巧等，欢迎广大业主积极参与。',
 3, '2026-05-18 11:00:00'),

('关于小区大门门禁系统升级的通知',
 '为进一步提升小区安全防范水平，物业将于6月1日至6月3日对小区大门及单元门禁系统进行升级改造，届时请各位业主携带门禁卡出入，访客请配合保安登记。',
 2, '2026-05-16 15:30:00'),

('端午节社区文化活动通知',
 '粽叶飘香，端午将至。物业将于5月31日（周日）上午9:00在小区广场举办"包粽子、庆端午"社区文化活动，现场备有糯米粽叶等材料，欢迎各位业主携家人参加！',
 4, '2026-05-19 08:30:00'),

('关于加强小区电动车规范停放的通知',
 '近期巡查发现部分楼道及单元门口存在电动车违规停放现象，存在严重消防安全隐患。请各位业主将电动车停放至指定车棚充电区。自5月25日起，违规停放车辆将被统一清理。',
 5, '2026-05-14 10:00:00');
