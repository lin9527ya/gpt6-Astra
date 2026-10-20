# [gpt6 Astra-claude全模型支持-grok4.7-DeepSeek v4.1 Flash 10.17版本-glm5.3全模型支持-gemini全模型支持破甲越狱](https://github.com/3641397194-wq/gpt6-Astra) Desktop

完整桌面工作台：启动页、指挥台、五档工作档位、五个 BREAK//OPEN 通道、六个模型席位（含 GLM 5.3全模型支持与 Gemini全模型支持）、明确目标输入、活动流、结果面板、隔离状态与社群入口。

六个席位的「预览 / 运行 / 检查 / 恢复」都会写入该模型自己的本地指令层：Codex `model_instructions_file`、Claude `CLAUDE.md`、Grok `AGENTS.md` / skills、DeepSeek v4.1 Flash 10.17版本 官方 Harness `$DSH_HOME` / `~/.dsh` 的 `AGENTS.md` / skills、GLM `GLM.md`、Gemini `GEMINI.md`。原稿备份在各自 `cha-backups\`。

## 启动

```powershell
npm install
npm start
```

Linux 上如果本机内核的 seccomp 过滤层会让 Chromium 渲染进程崩溃（窗口全黑），启动时会先探测一次，只在探测失败时关掉 seccomp 这一层并自动重启：命名空间沙箱、`contextIsolation` 与页面 CSP 都保持不变。探测正常时不做任何改动，Windows / macOS 完全不探测。

以 root 运行：Chromium 不允许 root 带沙箱启动（`FATAL: Running as root without --no-sandbox is not supported`），而这个开关只能在进程启动前给出，JS 层够不到。所以 deb 装完会生成一个 root 感知启动器，`/usr/bin/coldbrew-zero` 与桌面项都指向它：`uid=0` 时自动补 `--no-sandbox`，普通用户走原路径、沙箱保持开启。AppImage 沿用 electron-builder 默认的 `--no-sandbox` 桌面项。从普通用户会话里 `sudo` 起图形界面还有第二道墙是 X 授权，需要先 `xhost +SI:localuser:root`。桌面程序以 root 运行会把配置写成 root 所有，能不用就不用。

打包 Windows 便携版：

```powershell
npm run pack:win
```

品牌启动词是 `冷咖啡`，控制词是 `BREAK//OPEN`，当前版本为 `3.2.0-preview.2`。 DeepSeek 席位显示为 DeepSeek v4.1 Flash 10.17版本，在 Windows、macOS、Linux 三端对接 10.17 版官方 Harness `0.2.1-rc.2`；共享 `$DSH_AGENTS_HOME` / `~/.agents` 目录保留原样。详细安装合同见 [DeepSeek Harness 安装说明](../docs/SEAT-PACKS.md#deepseek-官方-harness-安装说明)。启动词 `冷咖啡` 会先打出三个 QQ 群号，再打出激活页。工单先口语归一再全自动打到 80 条小类三拍。

## 原创工具箱 1.0

左侧工具箱现已集成原创网络、网站、文件和文本程序，以及 AI 工具反馈循环与 MCP。使用和验收范围见 [原创工具箱说明](../docs/original-toolbox.md)。运行 `npm run test:toolbox` 验证工具，运行 `npm run test:toolbox:ui` 验证桌面界面。

## 三系统发布

GitHub Actions 在原生 Windows、macOS arm64 / x64、Linux x64 环境中执行检查、构建及打包版 UI 测试。安装包仅在全部平台通过后公开到 GitHub Releases，附带 SHA256SUMS.txt。macOS 包未做 Apple Developer 签名和公证，首次打开按系统提示确认。
