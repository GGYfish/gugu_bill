# 咕咕鱼记账 (gugu_bill)

> AI 智能全自动记账 App —— 基于 Flutter 3.10+ / Dart 3 的本地优先、移动端离线可用、AI 自动识别记账的全功能个人记账应用。

`demo_app` 是 **咕咕鱼记账** App 的官方 Demo 工程。基于 `flutter create` 空白项目增量开发而来,不替换整个工程,保留 Flutter 官方模板的所有原生壳(android / ios / web / macos / linux / windows)。

Mock 模式优先 —— 无需后端即可完整运行,可一键切换到真实后端。

---

## 目录

- [核心特性](#核心特性)
- [技术栈](#技术栈)
- [功能模块](#功能模块)
- [项目结构](#项目结构)
- [快速开始](#快速开始)
- [构建 & 运行](#构建--运行)
- [代码生成](#代码生成)
- [主题与颜色规范](#主题与颜色规范)
- [数据存储规范](#数据存储规范)
- [离线同步 & SourceHash](#离线同步--sourcehash)
- [Android 原生集成](#android-原生集成)
- [业务约束](#业务约束)
- [常见问题](#常见问题)

---

## 核心特性

- **AI 自动记账**:Android 端基于无障碍服务(AccessibilityService)监听通知,AI 解析银行/支付/短信文本,自动结构化金额、商户、来源,生成账单候选。
- **防重复 SourceHash**:每次识别的来源文本使用 SHA-256 生成 `sourceHash`,相同文本不会重复入账。
- **离线优先**:断网时所有写操作进入 `offline_sync_queue` 队列,标 `isLocalTemp=1`;网络恢复后自动后台同步,单条失败保留队列下次重试。
- **本地数据库**:Drift / SQLite 全本地存储,无后端可完整使用。
- **Mock 模式**:内置 `mockMode` 开关,所有接口内存模拟返回,真实后端零代码改动切换。
- **主题中心**:内置多套主题 + 用户可自定义主题,所有颜色跟随主题动态切换(深浅双套色值)。
- **完整 4 Tab**:首页 / 记一笔 / 负债台账 / 数据统计 + 设置 + 主题中心 + 资源管理。
- **双端差异化**:Android 支持无障碍监听,iOS / 其他平台自动关闭监听,仅展示系统限制提示。

---

## 技术栈

| 领域 | 选型 |
|---|---|
| 框架 | Flutter 3.10+ / Dart 3.9+ |
| 状态管理 | Provider 6.x (`ChangeNotifier` + `MultiProvider`) |
| 本地数据库 | Drift 2.22 + sqlite3_flutter_libs |
| 网络 | Dio 5.7 + connectivity_plus 6.1 |
| 路由 | fluro 2.0 |
| 图表 | fl_chart 0.70 |
| 权限 | permission_handler 11.3 |
| 偏好存储 | shared_preferences 2.3 |
| 工具 | intl / uuid / crypto(SHA-256) / share_plus / file_picker / flutter_colorpicker |

> 严格遵守 `.cursorrules` 中规定的版本,**禁止随意升级大版本**。

---

## 功能模块

### 四 Tab 主框架 (`lib/main.dart` `MainNavigation`)

| Tab | 名称 | 页面 | 主要能力 |
|---|---|---|---|
| 0 | 首页 | `home_page.dart` | 本月收支卡片、自动记账状态提示、离线待同步数量、待确认账单入口、时间流账单列表、多选模式 |
| 1 | 记一笔 | `record_page.dart`(独立 push) | 手动记账(收入/支出/转账)、账户选择、分类、备注、时间,自动 + AI + OCR 待确认流转正 |
| 2 | 负债 | `debt_page.dart` | 负债概览、列表(全部/未结清/已结清)、超期高亮、新增/编辑/删除、登记还款、还款流水、AI 识别弹窗确认 |
| 3 | 数据统计 | `statistics_page.dart` | 日/周/月/年时间筛选、饼图、折线图、消费排行、AI 文案 |

### 辅助页面

- `add_category_page.dart` 分类管理(增删子分类、改图标颜色)
- `add_liability_page.dart` 新增 / 编辑负债
- `setting_page.dart` 设置(自动记账开关、权限跳转、清理缓存、一键清空本地数据)
- `theme_center_page.dart` 主题中心(切换 / 自定义主题)
- `resource_management_page.dart` 资源管理(银行、信贷机构、消费分类等)

### 设置能力 (`setting_page.dart`)

- 自动记账开关(无障碍服务)
- 权限跳转(无障碍服务设置页)
- 清理缓存
- 一键清空本地数据(事务清空全部 6 张业务数据表)
- Mock 模式开关

---

## 项目结构

```
lib/
├── main.dart                 # 程序入口,组装 MultiProvider + MaterialApp
├── ui_constants.dart         # 颜色 / 尺寸 / 字体 / 圆角 / 间距,禁止硬编码
│
├── core/                     # (预留)核心封装
├── android_channel/
│   ├── auto_record_service.dart       # 自动记账服务:接收回调 → 创建账单
│   └── accessibility_channel.dart     # MethodChannel:无障碍服务开关/状态
│
├── database/
│   ├── database.dart         # Drift 数据库入口(表定义 + DAO + 默认数据)
│   └── database.g.dart       # 自动生成(勿手改)
│
├── pages/
│   ├── home_page.dart        # 首页
│   ├── record_page.dart      # 记一笔
│   ├── debt_page.dart        # 负债
│   ├── statistics_page.dart  # 数据统计
│   ├── add_category_page.dart
│   ├── add_liability_page.dart
│   ├── setting_page.dart
│   ├── theme_center_page.dart
│   ├── resource_management_page.dart
│   └── liability/
│       └── liability_theme.dart
│
├── providers/                # 全局 Provider(全部基于 ChangeNotifier)
│   ├── app_provider.dart           # db / 登录态 / 自动记账开关 / 离线数量
│   ├── bill_provider.dart
│   ├── category_provider.dart
│   ├── account_provider.dart
│   ├── liability_provider.dart
│   ├── statistics_provider.dart
│   ├── resource_provider.dart
│   └── record_category_provider.dart
│
├── services/
│   ├── network_service.dart
│   ├── backup_service.dart
│   └── backup_to_downloads.dart
│
├── theme/
│   ├── app_colors_data.dart   # 颜色数据类 + 内置主题预设(蓝/绿/紫/橙/...
│   └── theme_manager.dart     # 主题管理器(单例,持久化)
│
└── widgets/                  # 公共组件
    ├── common_widgets.dart           # Empty / Loading / Dialog
    ├── bank_selector.dart            # 银行选择器(数据库驱动)
    ├── credit_institution_selector.dart
    ├── credit_product_selector.dart
    ├── selector_widgets.dart         # 通用选择器
    ├── add_sub_category_dialog.dart
    └── time_range_picker.dart        # 时间区间选择
```

### 数据库表(Drift,全部在 `database.dart`)

| 表 | 用途 |
|---|---|
| `offline_sync_queue` | 离线写操作队列(网络恢复后自动同步) |
| `local_user_config` | 用户配置(mock 模式 / 自动记账开关 / 月预算 / 分类排序 / 分类使用次数) |
| `local_accounts` | 账户(现金/银行卡/支付宝/微信 等) |
| `local_bills` | 账单(收入/支出/转账) |
| `local_liabilities` | 负债主表 |
| `local_liability_repays` | 负债还款流水 |
| `local_categories` | 消费分类 |
| `local_banks` | 银行列表 |
| `local_credit_institutions` | 信贷机构列表 |

---

## 快速开始

### 环境要求

- Flutter 3.10+ / Dart 3.9+
- Android: Android Studio (JDK 17+,Android SDK 34)
- iOS: Xcode 15+ (仅可编译,iOS 无自动记账监听能力)
- Windows / macOS / Linux: 桌面调试支持

### 拉取依赖

```bash
flutter pub get
```

### 生成 Drift 代码

`database.g.dart` 必须由 `build_runner` 生成,**不要手改**。

```bash
dart run build_runner build --delete-conflicting-outputs
```

---

## 构建 & 运行

```bash
# 调试运行(自动选择已连接设备)
flutter run

# Android APK
flutter build apk --release

# Android App Bundle
flutter build appbundle

# iOS
flutter build ios --release

# 启动图标(可选)
dart run flutter_launcher_icons
```

构建日志见 `build_apk_log.txt`。

---

## 主题与颜色规范

**绝不能忘** —— 所有 UI 颜色必须从 `theme/app_colors_data.dart` 的 `AppColorsData` + `MaterialApp.theme` 动态读取,禁止硬编码 `Color(0xFF...)`。

- 业务色(分类标签、状态色)按 `isDark` 选两套色值:浅色用 500-700 饱和色,深色用 200-400 高明度。
- 删除 / 警示色统一使用主题的 `expense` 色,不使用 `Colors.red`。
- `const` 不能用于 `AppColors.xxx` 读取处,会被冻结、不响应主题切换。
- 反例 / 正例详见 `.cursorrules` 中"UI 颜色主题动态化"章节。

---

## 数据存储规范

**绝不能忘** —— 所有"可枚举的业务数据"必须存数据库(Drift 表 + DAO),禁止在 Dart 源码里写 `static const List<XXX> = [...]`。

- 银行列表 → `local_banks` + `getAllBanks()`
- 信贷机构 → `local_credit_institutions`
- 消费分类 → `local_categories`
- 负债类型 → `local_liabilities`(type 字段)
- 账户类型 → `local_accounts`
- 商户 / 标签 / 图标字典 → 对应表
- 颜色 / 尺寸 / 字体 / 路由 / 枚举 → `ui_constants.dart` / `enum` / 常量,不在此限制内

页面读取统一走 Provider + `StreamBuilder.watchAllXxx()` 或 `FutureBuilder.getAllXxx()`,禁止 `import 'xxx_data.dart'` 拿硬编码常量。

---

## 离线同步 & SourceHash

### 离线队列 (`offline_sync_queue`)

| status | 含义 |
|---|---|
| 0 | 待同步 |
| 1 | 同步中 |
| 2 | 已同步(可清理) |
| 3 | 失败(保留队列,下次重试) |

`connectivity_plus` 监听网络变化,网络恢复时在 `AppProvider._processSyncQueue()` 中遍历处理,单条失败不打断后续任务。

### SourceHash(防重复)

```dart
String sourceHash = sha256.convert(utf8.encode('${source}_${amount}_${remark}')).toString();
```

短信 / 通知 / 语音 / OCR 来源全部生成 SHA-256 写入 `local_bills.sourceHash`,批量插入前先 `WHERE sourceHash = ?` 去重。

---

## Android 原生集成

Dart 无法直接监听系统通知 / 短信,Android 端通过 **无障碍服务(AccessibilityService)** 监听屏幕内容。

- 跳转到系统无障碍设置:`AccessibilityChannel().openSettings()`
- 查询授权状态:`AccessibilityChannel().isEnabled()`
- 解析出的账单候选回传 Dart:`AutoRecordService.instance.onBillCreated`

iOS / 其他平台自动关闭监听能力,UI 上仅展示系统限制提示。

---

## 业务约束(摘自 `.cursorrules`)

1. **前端禁止金额计算**:统计、收支全部由 mock / 后端返回,前端只渲染。
2. **离线写 → 队列 → 自动同步**,失败保留队列下次重试。
3. **sourceHash SHA-256 防重复**。
4. **AI 识别负债只弹窗**,绝不自动建记录。
5. **转账账单不计入收支**。
6. **双端差异化**:Android 监听,iOS 关闭。
7. **OCR 只存图片 url**,不存二进制。
8. **退出登录 / 一键清空**事务清空 6 张数据表。
9. **优先 StreamBuilder + watch**,避免 setState。
10. **mockMode 一键切换**,业务代码无需改动。
11. **禁止业务数据字典硬编码**,走数据库 + DAO。

---

## Android Gradle 避坑(历史踩坑记录)

1. **Kotlin DSL(.kts)**:写 maven 镜像时必须使用 `maven { url = uri("https://...") }`,**禁止** Groovy 风格的 `url 'xxx'`(会 `Unexpected token`)。
2. **Kotlin 与 Java 版本匹配**:Java 17 → Kotlin 1.9+;Java 25 → Kotlin 2.0.0+。
3. **Gradle 版本与 AGP 匹配**:AGP 8.9 → Gradle 8.11.1+。
4. **镜像源**:必须同时修改 `buildscript.repositories` 和 `allprojects.repositories`,缺一处会卡死。
5. **改完 `.kts` / `.gradle` 一定要 `flutter clean` 再 `flutter run`**,否则可能复用旧编译缓存继续报错。

---

## 常见问题

**Q: 改了 `database.dart` 后没有生效?**
A: 必须重新执行 `dart run build_runner build --delete-conflicting-outputs` 重新生成 `database.g.dart`。

**Q: 主题切换后某些组件没变色?**
A: 检查是否在读取 `AppColors.xxx` 时加了 `const`,或硬编码了 `Color(0xFF...)`。

**Q: Android 真机无障碍服务监听不到?**
A: 进入 `设置 → 无障碍 → 已安装的服务 → 咕咕鱼记账`,确认开关打开并授权;然后回 App 让 `AppProvider.refreshPermissions()` 刷新状态。

**Q: iOS 测不到自动记账?**
A: 设计如此,iOS 不开放系统监听,UI 会展示系统限制说明。

**Q: 一键清空会删除什么?**
A: 事务清空全部 6 张业务数据表(账户/账单/负债/负债还款/分类/银行/信贷机构)+ 离线同步队列;用户配置保留。

---

## 许可与说明

`demo_app` 工程为咕咕鱼记账 App 官方 Demo,Mock 模式即可独立运行,可作为产品演示、二次开发模板、Flutter 实战参考。
