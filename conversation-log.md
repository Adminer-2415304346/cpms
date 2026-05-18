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
