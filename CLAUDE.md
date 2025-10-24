# CLAUDE.md

本文件为 Claude Code (claude.ai/code) 在此代码库中工作时提供指导。

## 项目概述

VoiceLog 是一个基于 SwiftUI 构建的 iOS 语音日记应用，允许用户录制音频条目，使用语音识别进行转录，并生成 AI 驱动的摘要。该应用包括 watchOS 支持、小组件和用于 AI 处理的 Cloudflare Workers 后端。

## 开发命令

### 项目设置
```bash
# 安装依赖
bundle install

# 设置环境
cp .env.example .env
# 使用你的 HMAC_KEY 更新 .env 文件

# 生成 Arkana 密钥包
bundle exec bin/arkana

# 生成 Xcode 项目
xcodegen
```

### 本地化
```bash
# 从 CSV 生成本地化文件
rake l10n
# 或直接运行：
scripts/l10n Localizable.csv --swift Shared/Localization/LocalizedKeys.swift --root Shared/Localization
```

### 服务器部署
```bash
cd Server
npm install
npm run deploy  # 部署到 Cloudflare Workers
npm run start   # 本地开发
```

### 测试
```bash
# 运行单元测试（在 Xcode 中）
# 测试目标：VoiceLogTests

# 运行快照测试
# 测试目标：SnapshotTests（使用 Snapshot 配置）
```

## 架构

### 客户端（iOS/watchOS）
- **主应用**：基于 SwiftUI 的 iOS 应用，使用 Core Data 持久化
- **手表应用**：watchOS 伴侣应用，具有录制功能
- **小组件**：iOS 和 watchOS 小组件，用于快速访问
- **共享组件**：跨平台使用的通用代码

### 关键目录
- `Sources/App/`：主应用入口点、配置和应用级状态
- `Sources/Components/`：可重用的 SwiftUI 组件
- `Sources/DataModel/`：Core Data 模型和持久化层
- `Sources/Services/`：业务逻辑（转录、音频、IAP、导出）
- `Sources/Models/`：数据模型和枚举
- `Shared/`：跨平台代码（音频录制、连接性、本地化）
- `Packages/`：本地 Swift 包（XLog、XLang、ArkanaKeys）

### 后端（Cloudflare Workers）
- `Server/src/worker.js`：处理转录和摘要请求的主要 Worker
- 与 OpenAI API 集成，进行语音转文本和聊天补全
- 支持 HMAC 认证和请求验证

## 关键技术

### iOS/watchOS
- **SwiftUI**：UI 框架
- **Core Data**：本地持久化（MemoEntity、SummaryEntity）
- **KeychainAccess**：安全 API 密钥存储
- **DSWaveformImage**：音频可视化
- **ConfettiSwiftUI**：庆祝效果
- **TPPDF**：PDF 导出功能

### 外部服务
- **OpenAI API**：Whisper 转录和 GPT 摘要
- **Cloudflare Workers**：无服务器后端部署
- **Apple Speech Framework**：设备端转录选项

### 开发工具
- **XcodeGen**：从 YAML 配置生成项目
- **Arkana**：安全密钥管理
- **Fastlane**：iOS 部署自动化
- **Ruby/Rake**：本地化和构建脚本

## 配置

### 应用配置
- `Config.swift`：使用 @AppStorage 的集中式应用设置
- `Constants.swift`：API 端点、限制和应用元数据
- 环境变量存储在 `.env` 文件中

### 服务器配置
- `wrangler.toml`：Cloudflare Workers 配置
- 在 Cloudflare 仪表板中设置的环境变量：
  - `OPENAI_KEY`：OpenAI API 密钥（必需）
  - `HMAC_KEY`：认证密钥（可选）
  - `AI_MODEL`：默认 AI 模型（可选）

## 数据模型

### Core Data 实体
- **MemoEntity**：带有元数据的音频日记条目
- **SummaryEntity**：与备忘录关联的 AI 生成摘要

### 关键模型
- `TranscriptionProvider`：Apple vs OpenAI 转录
- `OpenAIChatModel`：GPT 模型选择
- `ServerType`：默认 vs 自定义服务器配置

## 构建配置

- **Debug**：带有 Core Data 调试的开发版本
- **Snapshot**：用于快照测试，带有 DEBUG 标志
- **AppStore**：带有生产签名的发布版本

## 本地化

- 使用基于 CSV 的本地化工作流
- `Localizable.csv` 包含英语和简体中文的翻译
- 生成的 Swift 文件提供对本地化字符串的类型安全访问

## URL Scheme

应用支持自定义 URL scheme：`voicelog://`
- 用于快速操作和 Siri 快捷指令集成
- 在 `AppState.openURL(_:)` 中处理

## 测试策略

- **单元测试**：`VoiceLogTests` 目标中的核心逻辑和工具
- **快照测试**：`SnapshotTests` 目标中的 UI 组件快照
- 使用 Snapshot 配置确保一致的测试环境

## IAP 和高级功能

- 高级产品 ID：`app.haibin.voicelog.premium`
- 高级用户的更高每日字符限制
- 通过 `IAPManager` 服务管理

## 安全考虑

- API 密钥安全存储在 Keychain 中
- 服务器请求的 HMAC 验证
- 代码或提交中不包含敏感数据
- 服务器配置使用环境变量