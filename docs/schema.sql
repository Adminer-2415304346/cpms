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
JOIN owner_room or ON r.room_id = or.room_id
JOIN owner o       ON or.owner_id = o.owner_id
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

-- 管理员
INSERT INTO user (username, password, role, real_name, phone, email) VALUES
('admin_super', 'e10adc3949ba59abbe56e057f20f883e', 'admin', '系统管理员', '13800000001', 'admin@cpms.com');

-- 物业人员
INSERT INTO user (username, password, role, real_name, phone, email) VALUES
('staff_zhang', 'e10adc3949ba59abbe56e057f20f883e', 'staff', '张物业', '13800000002', 'zhang@cpms.com'),
('staff_li', 'e10adc3949ba59abbe56e057f20f883e', 'staff', '李物业', '13800000003', 'li@cpms.com');

-- 业主用户
INSERT INTO user (username, password, role, real_name, phone, email) VALUES
('owner_wang', 'e10adc3949ba59abbe56e057f20f883e', 'owner', '王业主', '13900000001', 'wang@cpms.com'),
('owner_zhao', 'e10adc3949ba59abbe56e057f20f883e', 'owner', '赵业主', '13900000002', 'zhao@cpms.com'),
('owner_sun', 'e10adc3949ba59abbe56e057f20f883e', 'owner', '孙业主', '13900000003', 'sun@cpms.com');

-- 业主档案
INSERT INTO owner (user_id, name, id_card, phone, move_in_date) VALUES
(4, '王业主', '410101199001010001', '13900000001', '2024-06-01'),
(5, '赵业主', '410101199002020002', '13900000002', '2024-03-15'),
(6, '孙业主', '410101199003030003', '13900000003', '2025-01-10');

-- 楼栋
INSERT INTO building (building_name, floors, description) VALUES
('1号楼', 18, '高层住宅，2梯4户'),
('2号楼', 12, '小高层住宅，1梯2户');

-- 房间
INSERT INTO room (building_id, unit_name, room_number, area, room_type, status) VALUES
(1, '1单元', '101', 120.50, '三室两厅', 'occupied'),
(1, '1单元', '102', 120.50, '三室两厅', 'occupied'),
(1, '2单元', '201', 89.00, '两室一厅', 'occupied'),
(2, '1单元', '101', 140.00, '四室两厅', 'vacant'),
(2, '1单元', '102', 140.00, '四室两厅', 'vacant');

-- 业主-房间关联
INSERT INTO owner_room (owner_id, room_id, relation_type, start_date) VALUES
(1, 1, 'owner', '2024-06-01'),
(2, 2, 'owner', '2024-03-15'),
(3, 3, 'tenant', '2025-01-10');

-- 停车位
INSERT INTO parking_spot (spot_code, location, type, status) VALUES
('A001', '地下一层A区', '标准', 'occupied'),
('A002', '地下一层A区', '标准', 'available'),
('B001', '地下二层B区', '大型', 'available');

-- 车辆
INSERT INTO vehicle (owner_id, spot_id, plate_number, vehicle_type, color) VALUES
(1, 1, '豫A12345', '轿车', '白色');

-- 账单
INSERT INTO bill (room_id, fee_type, amount, period, due_date, status) VALUES
(1, '物业费', 2410.00, '2026-Q1', '2026-04-30', 'paid'),
(1, '物业费', 2410.00, '2026-Q2', '2026-07-31', 'unpaid'),
(2, '物业费', 2410.00, '2026-Q1', '2026-04-30', 'unpaid'),
(3, '物业费', 1780.00, '2026-Q1', '2026-04-30', 'overdue');

-- 缴费记录
INSERT INTO payment (bill_id, amount, pay_method, staff_id) VALUES
(1, 2410.00, '微信支付', 2);

-- 报修
INSERT INTO repair (owner_id, room_id, description, urgency, status, staff_id) VALUES
(1, 1, '卫生间水管漏水', 'high', 'completed', 2),
(2, 2, '客厅空调不制冷', 'medium', 'in_progress', 3);

-- 投诉建议
INSERT INTO complaint (owner_id, type, content, is_anonymous, status) VALUES
(3, 'complaint', '夜间电梯噪音过大，影响休息', 0, 'pending');

-- 公告
INSERT INTO announcement (title, content, publisher_id) VALUES
('关于小区停水通知', '因管道维修，5月20日8:00-18:00小区将停水，请各位业主提前做好准备。', 2),
('关于缴纳物业费的通知', '请各位业主按时缴纳2026年第二季度物业费，谢谢配合。', 2);
