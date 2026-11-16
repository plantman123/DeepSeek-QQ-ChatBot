# QQ 机器人部署说明（AstrBot + SnowLuma）

本目录是一套可直接运行的 QQ 机器人环境：**AstrBot** 负责大模型对话与插件，**SnowLuma** 负责把 QQ 客户端接入成标准 OneBot v11 协议端，两者通过**反向 WebSocket** 连接。

- 部署位置：`E:\dsh_qqbot`
- 部署日期：2026-11-12
- 适用系统：Windows 10 / 11（x64）
- QQ 账号：**由你本人登录设置**（本次部署未使用、也未保存任何 QQ 账号密码）

---

## 1. 架构与端口

```
QQ 客户端 (QQ.exe)
      │  注入/本地互操作
      ▼
SnowLuma  v2.4.2   ── 反向 WebSocket ──►  AstrBot  v4.29.4
WebUI :5099            ws://127.0.0.1:6199/ws        WebUI :6185
(OneBot v11 协议端)                                  (LLM / 插件 / 知识库)
```

| 服务 | 监听地址 | 说明 |
| --- | --- | --- |
| AstrBot WebUI | `http://127.0.0.1:6185` | 配置大模型、插件、日志 |
| AstrBot OneBot 反向 WS | `ws://127.0.0.1:6199/ws` | 供 SnowLuma 连接（含 Token 校验） |
| SnowLuma WebUI | `http://127.0.0.1:5099` | QQ 账号注入、OneBot 连接管理 |

三个端口均只监听本机回环地址，未被映射到公网。

---

## 2. 目录结构

```
E:\dsh_qqbot\
├─ AstrBot\                     AstrBot v4.29.4 源码
│  ├─ main.py                   官方入口
│  ├─ requirements.txt          Python 依赖清单
│  └─ data\                     运行数据（首次启动自动生成）
│     ├─ cmd_config.json        ★ 主配置（平台/模型/面板密码）
│     ├─ dist\                  WebUI 前端静态资源（v4.29.4）
│     ├─ plugins\               插件目录
│     ├─ logs\astrbot.log       运行日志
│     └─ data_v4.db             对话数据库
├─ SnowLuma\                    SnowLuma v2.4.2（win-x64 发行包，内置 Node.js）
│  ├─ index.mjs                 主程序
│  ├─ node.exe                  自带的 Node.js v24.22.1
│  ├─ config\
│  │  ├─ onebot.json            ★ OneBot 连接配置（已指向 AstrBot）
│  │  ├─ webui.json             面板登录密码（scrypt 哈希）
│  │  └─ runtime.json           面板端口等运行时设置
│  └─ logs\                     运行日志
├─ tools\
│  ├─ Python312\                嵌入式 Python 3.12.10（依赖已装好）
│  └─ selfcheck_onebot.py       本地自检脚本（可选，无需 QQ）
├─ run-astrbot.py               AstrBot 启动引导（见 6.1）
├─ start-astrbot.bat            启动 AstrBot
├─ start-snowluma.bat           启动 SnowLuma
├─ start-all.bat                依次启动两者（推荐）
├─ tmp\                         运行期临时目录（自动创建/清理）
└─ README.md                    本文件
```

> 两个项目的源码都来自 GitHub，但本机直连 GitHub 会被重置，实际是通过镜像站获取的，
> 详见「附录 A」。

---

## 3. 本次已完成的工作（部署清单）

| 项目 | 版本 | 位置 | 状态 |
| --- | --- | --- | --- |
| AstrBot | v4.29.4（源码） | `AstrBot\` | ✅ 依赖已装、可启动、WebUI 可登录 |
| AstrBot WebUI 面板 | v4.29.4 | `AstrBot\data\dist\` | ✅ 已放入并与核心版本匹配 |
| SnowLuma | v2.4.2（win-x64 发行包） | `SnowLuma\` | ✅ 可启动、WebUI 可登录 |
| Python 运行时 | 3.12.10 嵌入式 | `tools\Python312\` | ✅ 155 个依赖已安装 |
| OneBot 反向 WS | — | `ws://127.0.0.1:6199/ws` | ✅ 已实测打通（见 3.3） |
| QQ 账号登录 | — | SnowLuma WebUI | ⬜ **需要你本人完成** |
| 大模型 API Key | — | AstrBot WebUI | ⬜ **需要你填写** |

### 3.1 登录凭据

| 系统 | 用户名 | 初始密码 | 说明 |
| --- | --- | --- | --- |
| AstrBot WebUI (`:6185`) | `astrbot` | `AstrBot2026` | 首次登录会强制要求修改 |
| SnowLuma WebUI (`:5099`) | `admin` | `SnowLuma2026` | 建议登录后立即修改 |
| OneBot 通信 Token | — | `dsh_qqbot_onebot_2026` | 两端已写死一致，改则需两边同时改 |

> Token 已同时写入：
> - AstrBot：`AstrBot\data\cmd_config.json` → `platform[0].ws_reverse_token`
> - SnowLuma：`SnowLuma\config\onebot.json` → `networks.wsClients[0].accessToken`

### 3.2 关键配置（已预置，无需改动即可联通）

AstrBot `data\cmd_config.json`：

```json
"platform": [
  {
    "id": "qq_onebot",
    "type": "aiocqhttp",
    "enable": true,
    "ws_reverse_host": "127.0.0.1",
    "ws_reverse_port": 6199,
    "ws_reverse_token": "dsh_qqbot_onebot_2026"
  }
]
```

SnowLuma `config\onebot.json`：

```json
"networks": {
  "httpServers": [],
  "httpClients": [],
  "wsServers": [],
  "wsClients": [
    {
      "name": "astrbot",
      "enabled": true,
      "url": "ws://127.0.0.1:6199/ws",
      "accessToken": "dsh_qqbot_onebot_2026",
      "role": "Universal",
      "messageFormat": "array",
      "reportSelfMessage": false
    }
  ]
}
```

### 3.3 已完成的连通性验证

在不登录任何 QQ 账号的前提下，已用本地自检脚本模拟 OneBot 协议端验证了完整链路：

- AstrBot 正常启动，`6185` / `6199` 监听成功；
- 反向 WebSocket 握手成功（Token + `X-Client-Role` + `X-Self-ID` 均被接受）；
- 上报一条 `/help` 私聊事件后，AstrBot 正确下发 `send_private_msg` 动作并输出帮助文本；
- AstrBot 日志出现 `aiocqhttp(OneBot v11) 适配器已连接。`；
- SnowLuma 能正确解析 `config\onebot.json`，WebUI 登录接口返回 200。

**尚未验证的部分**：真实 QQ 登录、注入 QQ 进程、收发真实 QQ 消息——这些必须由你用自己的账号完成。

---

## 4. 前置条件

1. Windows 10/11 x64。
2. **已安装并登录 PC 版 QQ（Windows NT 客户端）**——SnowLuma 属于注入式运行时，通过把
   `native\snowluma-win32-x64.dll` 注入到正在运行的 `QQ.exe` 进程来工作，所以必须先登录 QQ，
   且 QQ 需保持运行。
3. 一个可用的大模型服务（如 DeepSeek、OpenAI、通义千问、Ollama 等）的 API Key 或地址。
4. 端口 `6185`、`6199`、`5099` 未被占用。
5. 首次启动 SnowLuma 时，需要你在面板上亲自同意它的《EULA》与《隐私政策》
   ——本次部署**没有**代你同意任何协议。

---

## 5. 从启动到运行的完整流程

### 5.1 启动两个服务

双击 **`start-all.bat`**（推荐）——它会先开 AstrBot，延迟 8 秒再开 SnowLuma，各弹一个窗口。

也可以分开启动（顺序重要，AstrBot 必须先起来）：

```
1) start-astrbot.bat     ← 窗口标题显示 WebUI: 6185
2) start-snowluma.bat    ← 窗口标题显示 WebUI: 5099
```

> 两个窗口**都不要关**，关掉即停止服务。启动脚本已设置 UTF-8 代码页，
> 中文日志不会乱码。

### 5.2 登录 AstrBot 面板并改密

1. 浏览器打开 `http://127.0.0.1:6185`
2. 用户名 `astrbot`，密码 `AstrBot2026`
3. 按提示设置新密码（至少 8 位，含大小写字母和数字）
我修改成了 `yingdangsenlinchatbot123`

### 5.3 登录 SnowLuma 面板、同意协议

1. 浏览器打开 `http://127.0.0.1:5099`
2. 首次进入会先显示协议确认页，阅读后**由你本人点击同意**（同意后才能进入面板）；
3. 用 `admin` / `SnowLuma2026` 登录，随后建议在「设置」里修改密码。

### 5.4 把 QQ 接入 SnowLuma

1. 确认 PC 版 QQ 已登录并保持运行；
2. 在 SnowLuma 面板进入**账号 / 进程**页面，会列出可注入的 `QQ` 进程（形如「N 进程 · M 可注入」）；
3. 选择你的 QQ 进程执行**进程注入**，成功后该 QQ 账号显示为「在线 / 已接入」；
4. SnowLuma 会按 `config\onebot.json` 里的 `wsClients` 自动连到 AstrBot，无需再填地址。

> 若注入失败：优先尝试**以管理员身份运行** `start-snowluma.bat`；
> 关闭并重开 QQ 再试；QQ 大版本更新后可能需要等待 SnowLuma 跟进适配。

### 5.5 确认 OneBot 已连上 AstrBot

看 AstrBot 的控制台窗口（或 `AstrBot\data\logs\astrbot.log`），出现这行即成功：

```
[INFO] [aiocqhttp.aiocqhttp_platform_adapter:107]: aiocqhttp(OneBot v11) 适配器已连接。
```

也可以在 AstrBot 面板「平台 / 机器人」页看到 `qq_onebot` 平台处于运行状态。

### 5.6 配置大模型（否则机器人只会回内置命令）

1. AstrBot 面板左侧进入**服务提供商 / 模型提供商**；
2. 点击**新增**，选择服务类型（OpenAI 兼容 / DeepSeek / Gemini / Ollama …）；
3. 填入 API Key、接口地址、模型名，保存并**启用**；
4. 可随时在面板的「对话」页先测试模型是否可用。

> 未配置模型时，机器人仍能响应 `/help`、`/reset` 等内置命令，
> 但不会进行 AI 对话——这是判断「链路是否通」的最快方式。

### 5.7 在 QQ 里测试

用另一个 QQ 号（或让朋友）给机器人发消息：

| 发送内容 | 预期结果 |
| --- | --- |
| `/help` | 返回 AstrBot 内置命令列表 |
| `/你好` | 由大模型回复（需先完成 5.6） |
| `#sl` | SnowLuma 的状态命令，直接返回连接状态 |

注意：AstrBot 默认**唤醒前缀为 `/`**，不带前缀的消息不会触发 AI 回复。
若想让机器人对私聊“随便聊”，可在 AstrBot 面板 → 配置 → 其他 → **唤醒前缀** 中清空。

---

## 6. 配置细节与运维

### 6.1 为什么多了一个 `run-astrbot.py`

`tools\Python312` 是**嵌入式** Python，其 `python312._pth` 会让解释器以隔离模式运行，
不会把脚本所在目录加入 `sys.path`，直接执行 `AstrBot\main.py` 会报
`ModuleNotFoundError: No module named 'runtime_bootstrap'`。
`run-astrbot.py` 只做三件事：把 `AstrBot\` 加入 `sys.path`、切换工作目录、以 `__main__`
方式运行 `main.py`，行为与官方 `python main.py` 一致。

### 6.2 日常启停

- **启动**：双击 `start-all.bat`
- **停止**：关闭两个黑窗口，或在窗口内按 `Ctrl + C`
- **重启**：先关 AstrBot 再关 SnowLuma；启动时顺序相反（AstrBot 先起）

### 6.3 日志位置

| 内容 | 路径 |
| --- | --- |
| AstrBot 运行日志 | `AstrBot\data\logs\astrbot.log` |
| AstrBot 控制台 | 启动窗口 |
| SnowLuma 运行日志 | `SnowLuma\logs\snowluma-YYYY-MM-DD.log` |
| SnowLuma 控制台 | 启动窗口 |

### 6.4 自检脚本（无需 QQ）

在 AstrBot 运行中，另开一个 PowerShell：

```powershell
cd E:\dsh_qqbot
$env:PYTHONNOUSERSITE='1'
.\tools\Python312\python.exe .\tools\selfcheck_onebot.py
```

输出 `RESULT: OK` 表示 OneBot 反向 WS、事件上报、动作下发全链路正常。
该脚本只连本机回环地址，不会向真实 QQ 发送任何消息。

### 6.5 更新

**AstrBot**（保留 `data\` 即可保留全部配置与插件）：

1. 备份 `AstrBot\data\`
2. 下载新版源码解压覆盖 `AstrBot\`（不要删 `data\`）
3. `tools\Python312\python.exe -m pip install -r AstrBot\requirements.txt -i https://pypi.tuna.tsinghua.edu.cn/simple`
4. 如新版 WebUI 版本号变化，将对应 `AstrBot-<版本>-dashboard.zip` 解压出的 `dist\` 覆盖到 `AstrBot\data\dist\`

**SnowLuma**：下载新发行包，解压后覆盖除 `config\` 之外的文件（保留 `config\` 即可保留账号与连接配置）。

### 6.6 备份

只需要备份两个目录：

- `AstrBot\data\`（配置、插件、知识库、数据库）
- `SnowLuma\config\`（OneBot 连接、面板密码）

---

## 7. 常见问题（FAQ）

**Q1：AstrBot 里一直等不到「适配器已连接」**
按顺序检查：
1. AstrBot 是否先启动了？`netstat -ano | findstr :6199` 有监听才算起。
2. QQ 是否已在 SnowLuma 里成功注入并「在线」？没注入就不会建立 OneBot 连接。
3. 两端 Token 是否一致（见 3.1）。
4. 看 SnowLuma 日志里是否有 `ws://127.0.0.1:6199/ws` 的连接失败/重连记录。

**Q2：端口被占用 / 启动即退出**

```powershell
netstat -ano | findstr :6199
taskkill /PID <占用进程PID> /F
```

同理检查 `6185`、`5099`。

**Q3：SnowLuma 注入 QQ 失败**
- 先以管理员身份运行 `start-snowluma.bat`
- 确认 QQ 是官方 Windows NT 客户端且已登录
- 关闭 QQ 全部进程后重开，再回面板重新注入
- QQ 自动更新后接口可能变化，需要等 SnowLuma 更新

**Q4：面板打不开**
对应窗口是否还在？是否被 360/杀软拦截？地址必须是 `127.0.0.1`（已限制只监听本机）。

**Q5：机器人收到消息但不回复 AI**
- 是否配置并启用了模型提供商（5.6）
- 消息是否带 `/` 唤醒前缀
- 是否被白名单拦了：AstrBot → 配置 → 访问控制 → 白名单 ID 列表
  （默认为空 = 不限制）

**Q6：中文日志乱码**
启动脚本已 `chcp 65001`；若手动命令行启动，先执行 `chcp 65001` 再运行。

**Q7：`Could not install packages... Access is denied`（装依赖时）**
本项目运行时是嵌入式 Python，安装依赖时请带上隔离参数：

```powershell
$env:PYTHONNOUSERSITE='1'
.\tools\Python312\python.exe -m pip install -r .\AstrBot\requirements.txt -i https://pypi.tuna.tsinghua.edu.cn/simple
```

---

## 8. 安全与合规提醒

- 三个服务都只监听 `127.0.0.1`，**不要**把 `6185/6199/5099` 映射到公网或路由器端口转发。
- 请立即修改两个面板的初始密码；OneBot Token 建议一并改成你自己的随机串（两端同时改）。
- SnowLuma 属于第三方 QQ 互操作项目，与腾讯无隶属关系；使用它对 QQ 账号存在被风控/封禁的风险，
  请自行评估并遵守《QQ 用户协议》及当地法律。本项目仅用于学习与技术研究。
- 注入式运行会导致 QQ 客户端进程被修改，建议不要在该 QQ 上处理重要资产。

---

## 附录 A：本次部署的实际做法（含网络受限处理）

本机**无法直连 GitHub**（`github.com` 的 TLS 连接被重置），因此：

| 用途 | 实际使用的源 |
| --- | --- |
| AstrBot 源码 | `https://ghfast.top/https://github.com/AstrBotDevs/AstrBot/archive/refs/tags/v4.29.4.zip` |
| AstrBot WebUI 面板 | `.../releases/download/v4.29.4/AstrBot-v4.29.4-dashboard.zip`（同一镜像） |
| SnowLuma 发行包 | `https://ghfast.top/https://github.com/TomyJan/SnowLuma/releases/download/v2.4.2/SnowLuma-v2.4.2-win-x64.zip` |
| Python 3.12.10 | `https://mirrors.huaweicloud.com/python/3.12.10/python-3.12.10-embed-amd64.zip` |
| Python 依赖 | 清华镜像 `https://pypi.tuna.tsinghua.edu.cn/simple` |

- SnowLuma 发行包已用官方 `checksums.sha256` 校验通过
  （`SnowLuma-v2.4.2-win-x64.zip` = `0912926c5e73260f35b000278a8658493fc9452f36782c32fa86f0e825bad81a`）。
- Python 安装包来自 Python 官网同源文件，签名校验为 `Python Software Foundation`。
- 本机 `py` 启动器里登记的 Python 3.12 / 3.11 路径已失效（文件不存在），因此改用**嵌入式**
  Python 装在 `tools\Python312`，不修改系统 PATH、不写注册表，删除目录即可完全卸载。

如果你之后能正常访问 GitHub，可直接用官方方式部署，命令见附录 B。

## 附录 B：从零开始的官方部署命令（备查）

```powershell
git clone https://github.com/AstrBotDevs/AstrBot.git
cd AstrBot
uv sync          # 或 pip install -r requirements.txt
uv run main.py   # 或 python main.py
```

SnowLuma：到 `https://github.com/SnowLuma/SnowLuma/releases` 下载对应平台发行包，
解压后运行 `launcher.bat`（Windows）。

## 附录 C：版本与来源

- AstrBot v4.29.4 — <https://github.com/AstrBotDevs/AstrBot> （AGPL-3.0）
- SnowLuma v2.4.2 — 发行包取自 <https://github.com/TomyJan/SnowLuma/releases>
  （`SnowLuma/SnowLuma` 组织页当前访问返回 404，该仓库是可用的发布来源；EULA 见项目内 `EULA.md`）
- 官方文档：AstrBot OneBot v11 接入 —— `AstrBot\docs\zh\platform\aiocqhttp.md`
