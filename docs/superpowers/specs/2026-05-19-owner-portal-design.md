# 业主端门户 — 设计方案

> CPMS 社区物业管理系统 · 2026-05-19 · 第六轮对话成果

---

## 1. 背景与目标

### 问题
当前 CPMS V1.0 是一个**管理后台**风格的 Web 应用：侧边栏导航、表格 CRUD 操作、紫蓝渐变企业主题。三角色（admin/staff/owner）共用同一套界面，业主登录后依然看到「用户管理」「楼栋管理」等后台菜单（仅被 v-if 隐藏），整体体验不适合面向住户的 C 端场景。

### 目标
构建一个**独立的业主端前端项目**，面向社区业主提供：
- 明亮温暖的消费级 UI（与后台同紫蓝基因但气质不同）
- 全宽卡片式布局，无侧边栏
- 仅展示业主本人数据（按 ownerId 过滤）
- 覆盖全部 7 个功能模块

### 约束
- 共用现有 Spring Boot 后端 API（零改动）
- 桌面端优先
- 遵循 impeccable 产品设计规范
- 独立 Vue 3 项目，不与管理后台代码混用

---

## 2. 架构概览

```
E:\cpms - 副本\
├── cpms-backend/            ← 不变，共用（Spring Boot, port 8080）
├── cpms-fontend/            ← 管理后台 V1.0（port 3000）
├── cpms-owner-frontend/     ← ★ 新建：业主端门户（port 3001）
└── docs/
```

### 项目内部结构

```
cpms-owner-frontend/
├── index.html
├── package.json
├── vite.config.js                 # proxy /api → localhost:8080, port 3001
└── src/
    ├── main.js
    ├── App.vue                    # ConfigProvider + 路由视图
    ├── api/
    │   └── index.js              # Axios 封装（baseURL: /api）
    ├── stores/
    │   └── user.js               # Pinia: userId/username/role/realName + ownerId
    ├── router/
    │   └── index.js              # 7 路由 + 登录守卫
    ├── styles/
    │   └── global.css            # 业主端主题（全新，不复用后台样式）
    ├── layouts/
    │   └── OwnerLayout.vue       # 白色顶栏 + 全宽内容区（max-width: 1200px）
    └── views/
        ├── HomeView.vue          # 业主首页（仪表盘）
        ├── BillView.vue          # 我的账单
        ├── RepairView.vue        # 报修维修
        ├── ComplaintView.vue     # 投诉建议
        ├── AnnounceView.vue      # 社区公告
        ├── ParkingView.vue       # 停车管理
        ├── ProfileView.vue       # 个人中心
        └── LoginView.vue         # 业主登录页
```

### 启动方式

| 终端 | 目录 | 命令 | 端口 |
|------|------|------|------|
| 1 | cpms-backend | `mvn spring-boot:run` | 8080 |
| 2 | cpms-fontend | `npm run dev` | 3000 |
| 3 | cpms-owner-frontend | `npm run dev` | 3001 |

三个项目独立运行，通过浏览器端口区分。两个前端都通过 Vite proxy 将 `/api` 转发至 `localhost:8080`。

---

## 3. 设计系统

### 3.1 色彩

延续管理后台紫蓝基因，往暖色方向偏移：

| 变量 | 值 | 用途 |
|------|------|------|
| 主色 | `#7c3aed` | 按钮、链接、选中态 |
| 强调色 | `#f59e0b` 琥珀 | 少量点缀：高亮数字、标签、图标 |
| 背景 | `#faf9f7` 暖灰白 | 页面底色 |
| 卡片底 | `#ffffff` | 所有卡片 |
| 顶栏 | `#ffffff` + 底部分隔线 | 亮色顶栏 |
| 正文 | `#1e1b2e` | 标题、正文 |
| 辅助文字 | `#787580` | 标签、时间、元信息 |
| 边框 | `#e8e5e0` | 卡片边框、分割线 |

### 3.2 排版

- 标题：系统字体栈，`font-weight: 600`
- 正文：14px 基准，行高 1.6
- 数字：`font-feature-settings: "tnum"` 等宽数字
- 卡片间距：24px

### 3.3 形状

- 卡片圆角：12px
- 按钮圆角：8px
- 标签/徽章圆角：6px
- 阴影：`0 1px 3px rgba(0,0,0,.06)` 默认，hover 抬升至 `0 4px 12px rgba(0,0,0,.08)`

### 3.4 impeccable 约束

- 禁止编排式页面入场动画（无交错淡入、无滑动序列）
- 禁止自定义滚动条
- 禁止渐变文字
- 色彩策略 Restrained（单色强调，功能优先）
- 过渡动画仅保留：路由切换 fade（200ms）、按钮 hover/active、Modal 弹出

---

## 4. 布局设计

### 整体布局（OwnerLayout.vue）

```
┌──────────────────────────────────────────────────┐
│  [Logo] CPMS·业主服务  [账单] [报修] [投诉] ...  👤 王业主 ▾ │  ← 白色顶栏，固定
├──────────────────────────────────────────────────┤
│                                                  │
│   ┌──────────────── content area ─────────────┐  │
│   │  max-width: 1200px, auto margin, padding  │  │
│   │                                           │  │
│   │  (各页面内容以卡片堆叠)                     │  │
│   │                                           │  │
│   └───────────────────────────────────────────┘  │
│                                                  │
└──────────────────────────────────────────────────┘
```

### 顶栏导航

| 导航项 | 路由 | 图标 |
|--------|------|------|
| 首页 | `/home` | HomeOutlined |
| 我的账单 | `/bills` | DollarOutlined |
| 报修维修 | `/repairs` | ToolOutlined |
| 投诉建议 | `/complaints` | MessageOutlined |
| 社区公告 | `/announces` | SoundOutlined |
| 停车管理 | `/parking` | CarOutlined |

用户头像下拉：个人中心、退出登录。

### 路由守卫
同管理后台模式：非登录页 → 检查 `store.isLoggedIn` → 未登录跳 `/login`。

---

## 5. 页面设计

### 5.1 登录页 `/login`

**设计**：简约居中卡片，暖色背景，去粒子动画和光斑。品牌标识 + 登录表单。

**关键字段**：用户名、密码、登录按钮。

**交互**：登录成功 → store.setUser() → 解析 ownerId → 跳转 `/home`。

### 5.2 首页 `/home`

**欢迎横幅**：`👋 下午好，王业主 — 2026年5月19日`，大卡片，时间感知问候。

**统计卡片行**（3 列）：
| 卡片 | 数据来源 | 内容 |
|------|---------|------|
| 待缴账单 | `GET /bills?roomId=X` 聚合 | 金额合计 + 笔数 |
| 进行中报修 | `GET /repairs?ownerId={ownerId}` | 计数（非终态工单） |
| 最新公告 | `GET /api/announcements` | 最近一条标题 |

**最近动态**：
- 最近 3 条报修（状态标签、时间）
- 最近 3 条公告（点击展开详情）
- 每条可点击跳转到对应模块

### 5.3 我的账单 `/bills`

**布局**：卡片式列表，每条账单一个卡片。

**卡片内容**：费用类型标签、房产（楼栋-单元-房号）、金额（大字突出）、账期、截止日期、状态标签（paid/unpaid/overdue）。

**操作**：未缴/逾期账单显示「立即缴费」按钮 → Modal 选择支付方式 → 调用 `POST /api/bills/{id}/pay`。

**数据获取**：`ownerId` → `GET /api/owner-rooms/by-owner/{ownerId}` → 对每个 roomId 调用 `GET /api/bills?roomId={roomId}` → 前端合并排序。

### 5.4 报修维修 `/repairs`

**布局**：顶部「提交报修」按钮（右侧）+ 报修列表。

**列表卡片**：描述摘要、所在房产、紧急度标签（绿/黄/红）、状态标签、时间。

**状态展示**：用 Step 步骤条展示当前工单进度：待处理 → 已派工 → 处理中 → 已完成 → 已确认。

**提交报修**：Modal 表单 — 选择我的房间、紧急度（low/medium/high）、问题描述。

**操作**：已完成的工单显示「确认完工」→ `PUT /api/repairs/{id}/confirm`。

### 5.5 投诉建议 `/complaints`

**布局**：顶部「提交投诉/建议」+ 列表。

**列表卡片**：类型标签（投诉红/建议蓝）、内容摘要、匿名标识、状态、时间、物业回复（如有）。

**提交**：Modal — 类型（complaint/suggestion）、内容、是否匿名。

### 5.6 社区公告 `/announces`

**布局**：纯展示列表，按时间倒序。

**卡片**：标题、发布时间、内容摘要。点击弹 Modal 看全文。

### 5.7 停车管理 `/parking`

**布局**：左右两栏或上下两张卡片。

**我的车位**：从车辆表关联查出绑定车位，显示车位编号、位置、类型、状态。

**我的车辆**：从 `GET /api/parking/vehicles?ownerId={ownerId}` 获取列表，显示车牌、类型、颜色、绑定车位。提供登记按钮（Modal 表单）。

### 5.8 个人中心 `/profile`

**单卡片**：个人信息展示（姓名、手机、身份证号、入住时间），只读。修改密码按钮 → Modal。

---

## 6. 数据流

### 6.1 Store 扩展

在管理后台 user store 基础上增加 `ownerId` 字段：

```js
// stores/user.js
state: {
  userId: null,
  username: '',
  role: '',
  realName: '',
  ownerId: null     // ★ 新增：登录后解析
}
```

### 6.2 登录后初始化流程

```
POST /api/auth/login
  → store.setUser({ userId, username, role, realName })
  → GET /api/owners/by-user/{userId}
    → store.ownerId = owner.ownerId
    → router.push('/home')
```

### 6.3 业主数据过滤模式

所有「我的」页面使用统一模式：
```
GET /api/owner-rooms/by-owner/{ownerId}   → 我的房间列表
GET /api/repairs?ownerId={ownerId}        → 我的报修
GET /api/complaints?ownerId={ownerId}     → 我的投诉
GET /api/parking/vehicles?ownerId={ownerId} → 我的车辆
GET /api/bills?roomId={roomId}            → 按房间查账单（遍历合并）
```

---

## 7. API 端点映射

| 页面 | 使用端点 |
|------|---------|
| 登录 | `POST /api/auth/login` |
| 首页 | `GET /api/owner-rooms/by-owner/{ownerId}`, `GET /api/bills?roomId=`, `GET /api/repairs?ownerId=`, `GET /api/announcements` |
| 账单 | `GET /api/owner-rooms/by-owner/`, `GET /api/bills?roomId=`, `POST /api/bills/{id}/pay` |
| 报修 | `GET /api/repairs?ownerId=`, `POST /api/repairs`, `GET /api/owner-rooms/by-owner/`, `PUT /api/repairs/{id}/confirm` |
| 投诉 | `GET /api/complaints?ownerId=`, `POST /api/complaints` |
| 公告 | `GET /api/announcements`, `GET /api/announcements/{id}` |
| 停车 | `GET /api/parking/vehicles?ownerId=`, `POST /api/parking/vehicles`, `GET /api/parking/spots` |
| 个人中心 | `GET /api/owners/{ownerId}`, `PUT /api/owners/{id}` |

---

## 8. 技术栈

| 层 | 技术 | 说明 |
|----|------|------|
| 框架 | Vue 3 (Composition API) + Vite | 同管理后台 |
| UI 库 | Ant Design Vue 4.x | 同管理后台 |
| 状态管理 | Pinia + persist | 扩展 ownerId |
| HTTP | Axios（复用封装） | baseURL: /api |
| 样式 | 全新 global.css | 不复用管理后台样式 |
| 语言 | JavaScript | 同管理后台 |

---

## 9. 验证

### 构建验证
```bash
cd cpms-owner-frontend
npm install
npm run build       # 零错误
```

### 功能验证
1. 用 `owner_wang / 123456` 登录 → 页面显示王业主的账单、报修、投诉
2. 缴费：选中一条 unpaid 账单 → 点击缴费 → 选择微信支付 → 确认 → 账单状态变为 paid
3. 提交报修：填写表单 → 提交 → 列表出现新工单（状态 pending）
4. 确认完工：对 completed 工单点「确认完工」→ 状态变为 confirmed
5. 投诉：提交一条匿名投诉 → 管理员端可见匿名标识
6. 停车：查看车辆列表 → 绑定车辆与车位
7. 登录后刷新页面 → 状态保持（localStorage）

### 对照 impeccable 检查
- 无自定义滚动条样式
- 无渐变文字
- 无编排式交错入场动画
- 色彩策略 Restrained，琥珀色仅少量点缀
