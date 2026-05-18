# 🏘️ CPMS - 社区物业管理系统

> Community Property Management System  
> 南京理工大学紫金学院 · 数据库系统课程设计 · 题目六

![Tech Stack](https://img.shields.io/badge/Vue-3.5-4fc08d?logo=vue.js) ![Tech Stack](https://img.shields.io/badge/Spring_Boot-3.5-6db33f?logo=springboot) ![Tech Stack](https://img.shields.io/badge/MySQL-8.0-4479a1?logo=mysql) ![Tech Stack](https://img.shields.io/badge/Java-25-ED8B00?logo=openjdk) 

---

## 📖 项目简介

CPMS 是一个面向社区物业管理的 Web 信息系统，支持多角色权限（管理员 / 物业人员 / 业主），涵盖房产管理、费用收缴、报修处理、投诉建议、公告发布、停车位管理等核心业务。

### 功能模块

```
📁 CPMS
├── 🔐 用户与权限管理    — 登录 / 注册 / 角色分配（admin / staff / owner）
├── 🏢 房产信息管理      — 楼栋 → 单元 → 房间 三级层级管理
├── 👥 业主信息管理      — 业主档案 / 入住迁出 / 房产绑定
├── 💰 物业费用管理      — 账单生成 / 在线缴费 / 欠费催缴
├── 🔧 报修管理          — 提交 → 派工 → 处理中 → 完成 → 确认 全流程
├── 💬 投诉与建议        — 业主提交 / 物业回复 / 匿名支持
├── 📢 公告通知          — 物业发布 / 全员查看
└── 🚗 停车位管理        — 车位登记 / 车辆绑定 / 使用记录
```

### 数据库设计

- **12 张数据表**：user / owner / building / room / owner_room / bill / payment / repair / complaint / announcement / parking_spot / vehicle
- **1 个视图**：`v_overdue_bills`（欠费催缴一览）
- **1 个触发器**：`tr_payment_after_insert`（缴费后自动更新账单状态）
- **14 个索引**：覆盖高频查询字段

ER 图：[docs/er-diagram.md](docs/er-diagram.md)

---

## 🛠 技术栈

| 层 | 技术 |
|----|------|
| **前端** | Vue 3 + Ant Design Vue 4 + Vite |
| **后端** | Spring Boot 3.5 + Spring Data JPA |
| **数据库** | MySQL 8.0 |
| **构建工具** | Maven 3.9 + npm |

---

## 🚀 快速启动

### 环境要求

- JDK 17+（本项目使用 JDK 25）
- Maven 3.9+
- MySQL 8.0+
- Node.js 18+

### 1. 克隆项目

```bash
git clone https://github.com/Adminer-2415304346/cpms.git
cd cpms
```

### 2. 初始化数据库

```bash
# 连接到 MySQL，执行建库脚本
mysql -u root -p --default-character-set=utf8mb4 < docs/schema.sql
```

### 3. 启动后端

```bash
cd cpms-backend

# 修改 src/main/resources/application.properties 中的数据库用户名密码
# spring.datasource.username=root
# spring.datasource.password=你的密码

mvn spring-boot:run
```

后端运行在 `http://localhost:8080`

### 4. 启动前端

```bash
cd cpms-fontend

npm install
npm run dev
```

浏览器打开 `http://localhost:3000`

### 5. 登录

| 账号 | 密码 | 角色 |
|------|------|------|
| `admin_super` | `123456` | 管理员 |
| `staff_zhang` | `123456` | 物业人员 |
| `owner_wang` | `123456` | 业主 |

---

## 📁 项目结构

```
cpms/
├── README.md
├── conversation-log.md          # 对话记录
├── docs/
│   ├── 需求分析.md               # Step 1: 需求分析文档
│   ├── diagrams.md              # 思维导图 + 流程图 Mermaid 代码
│   ├── er-diagram.md            # Step 2: ER 图 Mermaid 代码
│   ├── schema.sql               # 完整建库建表脚本
│   ├── 项目开发总结.md            # 数据库 + API 设计总结
│   └── 问题排查日志.md            # 启动排错记录
├── photo/                       # ProcessOn 绘制图表
├── cpms-backend/                # Spring Boot 后端
│   ├── pom.xml
│   └── src/main/java/com/cpms/
│       ├── entity/              # 12 个 JPA 实体
│       ├── repository/          # 12 个数据访问接口
│       ├── service/             # 10 个业务逻辑类
│       ├── controller/          # 10 个 REST 控制器
│       ├── config/              # CORS + 异常处理
│       └── dto/                 # 数据传输对象
└── cpms-fontend/                # Vue3 前端
    ├── package.json
    ├── vite.config.js
    └── src/
        ├── api/index.js         # Axios 封装
        ├── stores/user.js       # Pinia 用户状态
        ├── router/index.js      # 路由 + 鉴权
        ├── styles/global.css    # 全局主题样式
        ├── layouts/MainLayout.vue
        └── views/               # 10 个功能页面
```

---

## 📊 API 端点

| 模块 | 路径 | 核心接口 |
|------|------|----------|
| 认证 | `/api/auth` | POST `/login` |
| 用户 | `/api/users` | CRUD + 按角色筛选 |
| 楼栋 | `/api/buildings` | CRUD |
| 房间 | `/api/rooms` | CRUD + 按楼栋筛选 |
| 业主 | `/api/owners` | CRUD |
| 账单 | `/api/bills` | CRUD + 缴费 + 欠费查询 |
| 报修 | `/api/repairs` | CRUD + 派工→处理→完成→确认 状态机 |
| 投诉 | `/api/complaints` | CRUD + 回复 |
| 公告 | `/api/announcements` | 发布 / 查看 / 删除 |
| 停车 | `/api/parking` | 车位 + 车辆管理 |

完整 API 文档见 [docs/项目开发总结.md](docs/项目开发总结.md)

---

## 🎨 设计特色

- **紫蓝流光渐变 UI** — 登录页含浮动光斑动画 + Canvas 粒子网络
- **侧边栏渐变** — 深紫到深蓝配色
- **毛玻璃顶栏** — `backdrop-filter` 模糊效果
- **报修状态机** — 五阶段流转：待处理 → 已派工 → 处理中 → 已完成 → 已确认
- **统一响应格式** — `{code, message, data}`

---

## 📝 课程设计报告结构

```
1. 需求分析       → docs/需求分析.md
2. 功能设计       → docs/项目开发总结.md
3. 功能实现       → cpms-backend/ + cpms-fontend/
4. 系统测试       → docs/问题排查日志.md
5. 验收答辩       → 待完成
```

---

## 📄 License

本项目为数据库系统课程设计作业，仅供学习参考。

---

> 🏫 南京理工大学紫金学院 · 励学笃行  
> © 2026 CPMS Team
