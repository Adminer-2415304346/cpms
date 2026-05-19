# 社区物业管理系统（CPMS）- 项目对话记录

**课程**: 数据库系统课程设计 2026
**题目**: 题目6 - 社区物业管理系统设计与实现
**开始日期**: 2026-05-18

---

## 项目基本信息（来自PPT指导书）

| 项目 | 内容 |
|------|------|
| **题目编号** | 题目6 |
| **系统名称** | 社区物业管理系统设计与实现 |
| **核心要求** | 权限设置（管理员、业主），功能设计（增删改查） |
| **数据库要求** | 至少5张表，E-R图，关系模型，视图、索引、触发器各1个 |
| **系统要求** | SQL Server/MySQL/Oracle，任意语言（Java/PHP/Python/C++），Web或C/S架构 |
| **报告结构** | 1.需求分析 2.功能设计 3.功能实现 4.系统测试 5.验收答辩 |
| **考核标准** | 报告50分 + 演示运行20分 + 数据库知识点20分 + 考勤10分 |

---

## 确定的技术栈

| 层 | 技术 |
|----|------|
| **前端** | Vue 3 + JavaScript + Ant Design Vue |
| **后端** | Java + Spring Boot |
| **数据库** | MySQL |

---

## 对话记录

### [2026-05-18] 项目启动，需求分析阶段

- 确认题目：题目6 - 社区物业管理系统设计与实现
- 确认技术栈：Vue3 + JS + Ant Design Vue / Java + Spring Boot / MySQL（后端由Node.js改为Java，更正式）
- 确认功能范围：8个功能模块，3个用户角色
- 开始编写需求分析文档
- 完成需求分析文档（`docs/需求分析.md`）
- 绘制4张图：思维导图、总体业务流程、报修流程、缴费流程
- 完成 ER 图设计（12张表，Mermaid + ProcessOn）
- 完成建库 SQL（`docs/schema.sql`）：12张表 + 14个索引 + 1个视图 + 1个触发器 + 示例数据
- GitHub 仓库创建并推送：https://github.com/Adminer-2415304346/cpms

### [2026-05-18] 后端开发阶段

- 搭建 Spring Boot 3.2.5 + Java 17 + Maven 项目
- 创建 12 个 JPA 实体类（user/owner/building/room/owner_room/bill/payment/repair/complaint/announcement/parking_spot/vehicle）
- 创建 12 个 Repository 接口
- 创建 9 个 Service 业务类（User/Building/Room/Owner/OwnerRoom/Bill/Repair/Complaint/Announcement/Parking）
- 创建 10 个 Controller 控制器（Auth/User/Building/Room/Owner/OwnerRoom/Bill/Repair/Complaint/Announcement/Parking）
- 配置 CORS 跨域、全局异常处理、统一响应格式 ApiResult
- 调整 pom.xml 适配 JDK 25（Spring Boot 3.5.0 + Java 25）
- Maven 编译通过（51 个 Java 文件，零错误）

### [2026-05-18] 前端开发阶段

- 创建 Vue 3 + Vite + Ant Design Vue 4.x 项目（20 个源文件）
- 登录页：深蓝渐变背景 + 玻璃态卡片 + 紫金学院标识（龙形 SVG 图标、校名、校训）
- 主布局：侧边栏导航 + 面包屑 + 角色权限菜单 + 页脚校名
- 10 个功能页面：仪表盘 / 用户管理 / 楼栋 / 房间 / 业主 / 账单 / 报修(含状态流转) / 投诉 / 公告 / 停车
- 全部实现 CRUD 操作、表格展示、模态框表单、权限控制
- Axios 封装（统一错误处理）、Pinia 状态管理（用户持久化）
- Vite 构建通过（零错误，6.93s）
- 紫蓝主题统一：全局 CSS + 登录页粒子/光斑动画 + 仪表盘重设计 + 主布局渐变侧边栏

### [2026-05-18] 项目启动与排错

- 执行 schema.sql 建库（遇到 5 个 MySQL 问题，已解决）
- 启动 Spring Boot 后端（遇到 5 个编译/配置问题，已解决）
- 启动 Vite 前端（构建通过）
- 前后端联调：登录 API 测试通过
- 问题排查记录：`docs/问题排查日志.md`（11 个问题，含解决方案）

### [2026-05-18] 项目完善与交付

- 前后端联调完成：所有 10 个模块 API 均可正常调用
- 样式统一：紫蓝主题全局应用（登录页粒子/光斑动画 + 仪表盘重设计 + 侧边栏渐变 + 玻璃态卡片）
- 权限控制：3 个角色（admin/staff/owner）菜单差异化 + API 权限校验
- 文档完善：`docs/项目开发总结.md` 覆盖数据库设计、API 清单、前端页面、主题样式
- 项目提交：GitHub 仓库 [cpms](https://github.com/Adminer-2415304346/cpms)

### [2026-05-18] 第二轮：前后端联调 400 错误专项排查

- 用户测试系统发现大量 API 控制台报 400，开始全面 debug
- 发现并修复 7 个 Bug（其中 4 个致命 + 3 个功能）：
  - **致命**：日期序列化不匹配（Ant Design DatePicker → LocalDate 解析失败）
  - **致命**：全局异常处理器统一返回 400，无法区分错误类型
  - **致命**：JPA 实体缺少 Hibernate 代理忽略注解，懒加载可能触发序列化异常
  - **致命**：API 响应泄露 `User.password` 字段
  - **功能**：报修列表业主查询用错 ID（userId vs ownerId）
  - **功能**：投诉建议未按业主角色过滤
  - **功能**：缴费后账单状态未更新，可重复支付
- 变更量：后端 18 个文件、前端 2 个文件
- 问题排查记录更新至 `docs/问题排查日志.md`（扩展至 18 个问题，含第三～六章）
- 后端编译通过，前端 Vite 构建通过（9.70s）

### [2026-05-18] 第三轮：前端流转设计增强

- 用户要求优化前端界面，增加流转设计，让系统更美观
- 对 4 个核心文件进行全面增强：
  - **App.vue**：新增路由级页面过渡动画（滑动/反向滑动/淡入淡出，0.28s）
  - **global.css**：表格行交错入场、卡片悬浮发光、按钮光泽扫过、标签脉动、模态弹出、输入框聚焦光晕、自定义滚动条等 12 项动画
  - **MainLayout.vue**：侧边栏菜单滑动指示器 + 交错入场、Logo 旋转、顶栏头像脉冲光环、面包屑淡入、内容区滑入
  - **DashboardView.vue**：统计数字 easeOutCubic 递增动画、卡片交错入场 + 底部光晕、欢迎横幅形状漂浮、快捷入口箭头滑动
- 公告列表追加逐项交错入场动画
- 前端 Vite 构建通过（8.95s）
- 文档更新：`docs/项目开发总结.md` 补充流转动画清单、更新项目结构与配置说明

---

### [2026-05-19] 第四轮：详情弹窗 Modal 化 + 日志体系建设

- 用户要求记录更新日志和错误日志
- **投诉/报修详情增强**：
  - ComplaintList.vue：`message.info()` 替换为完整详情 Modal，展示类型/状态/匿名/编号/内容/回复/时间
  - RepairList.vue：`message.info()` 替换为完整详情 Modal，展示状态/紧急度/业主/楼栋房间/描述/时间
  - LoginView.vue：移除密码框回车登录快捷键
- **日志体系建设**：
  - 新建 `docs/CHANGELOG.md`：覆盖从项目初始化至今的 8 次提交
  - 确认复用 `docs/问题排查日志.md`（18 个已记录问题）作为错误日志
- 提交 `7d3fc04`

### [2026-05-19] 第五轮：UI 设计系统优化（impeccable polish）

- 安装 `pbakaus/impeccable` 前端设计技能
- 按 impeccable 产品设计规范进行全局优化：
  - **全局禁令清理**：移除自定义滚动条、渐变文字（页脚 Logo）、编排式页面加载序列（表格行/菜单项/卡片/面包屑交错动画）
  - **色彩策略降级**：从 Drenched（紫蓝渐变铺满）降为 Restrained（单色强调），色素中性化
  - **MainLayout.vue**：侧边栏从紫蓝渐变改为纯色暗底 `#14101f`，页脚纯色文字，菜单去交错动画
  - **DashboardView.vue**：欢迎横幅→简洁问候栏+日期标签，统计卡片打破 hero-metric 模板→横向数字+单位布局
  - **LoginView.vue**：光斑饱和降低、卡片左侧背景去紫蓝渐变、按钮去 shimmer 光泽动画
  - **App.vue**：添加全局空状态 ConfigProvider、页面过渡加速至 200ms
  - **AnnouncementList.vue**：移除 10 级列表项交错入场动画
  - **global.css**：净删除 300+ 行冗余动画代码
- 净删除 342 行，构建通过（7.24s）
- 提交 `8bc269f`

---

### [2026-05-19] 第六轮：业主端门户规划（启动）

- 用户提出业主端不应使用与管理后台相同的界面风格，需要做一个面向业主的美观展示前端
- 讨论方向：
  - 当前版本归档为 **V1.0**
  - 新开文件夹完整复制项目，在副本中开发业主端门户
  - 架构选型待定：同项目路由拆分 vs 独立前端项目
  - 设计工具：将继续使用 impeccable + frontend-design 技能
- 本轮为规划启动，实际开发将在新目录中进行

---

### [2026-05-19] 第七轮：业主端门户完整实现

- 断开副本的 GitHub remote，纯本地开发
- 确定架构：**独立前端项目** `cpms-owner-frontend/`，与 `cpms-fontend/` 平级，共用 `cpms-backend/`
- 确定设计方向：桌面端、温暖信赖（延续紫蓝基因）、全宽卡片式布局、7 模块全保留
- 设计方案写入 `docs/superpowers/specs/2026-05-19-owner-portal-design.md`
- 实现计划写入 `docs/superpowers/plans/2026-05-19-owner-portal.md`

**新增 (Added)**：
- `cpms-owner-frontend/` 完整 Vue 3 项目（14 个源文件）
  - 项目脚手架：`package.json`、`vite.config.js`（port 3001）、`index.html`
  - 核心入口：`main.js`、`App.vue`（ConfigProvider + fade 过渡）
  - 数据层：`api/index.js`（Axios 封装）、`stores/user.js`（Pinia + ownerId 扩展）
  - 路由：`router/index.js`（7 路由 + 登录守卫）
  - 布局：`layouts/OwnerLayout.vue`（白色顶栏 + 全宽 1200px 内容区）
  - 全局样式：`styles/global.css`（暖灰白底 #faf9f7、紫罗兰主色 #7c3aed、琥珀点缀 #f59e0b，Restrained 策略）
  - 页面：
    - `LoginView.vue` — 简约居中登录页，登录后解析 ownerId
    - `HomeView.vue` — 欢迎横幅 + 3 统计卡片（真实 API 数据）+ 最近报修/公告
    - `BillView.vue` — 按房产分组账单列表 + 缴费 Modal
    - `RepairView.vue` — 报修列表 + 步骤条状态追踪 + 提交报修 + 确认完工
    - `ComplaintView.vue` — 投诉列表（含物业回复）+ 提交投诉/建议
    - `AnnounceView.vue` — 公告列表 + 详情 Modal
    - `ParkingView.vue` — 我的车位（从车辆推断）+ 车辆列表 + 登记车辆
    - `ProfileView.vue` — 个人基本信息 + 修改密码

**构建验证**：
- `npm install` — 153 packages，零漏洞
- `npm run build` — 3250 模块，零错误，6.90s
- 共计 9 次 Git 提交
