# QQ 机器人部署说明

---


## 从启动到运行的完整流程

### 启动两个服务

双击 **`start-all.bat`** —— 先开 AstrBot，再开 SnowLuma，各弹一个窗口。

```
1) start-astrbot.bat     ← 窗口标题显示 WebUI: 6185
2) start-snowluma.bat    ← 窗口标题显示 WebUI: 5099
```

### 登录 AstrBot 面板并改密

1. 浏览器打开 `http://127.0.0.1:6185`
2. 用户名 `astrbot`，密码 `AstrBot2026`
3. 按提示设置新密码（至少 8 位，含大小写字母和数字）
我修改成了 `yingdangsenlinchatbot123`

### 登录 SnowLuma 面板、同意协议

1. 浏览器打开 `http://127.0.0.1:5099`
2. 首次进入会先显示协议确认页，阅读后**由你本人点击同意**（同意后才能进入面板）；
3. 用 `admin` / `SnowLuma2026` 登录，随后建议在「设置」里修改密码。

### 把 QQ 接入 SnowLuma

1. 确认 PC 版 QQ 已登录并保持运行；
2. 在 SnowLuma 面板进入**账号 / 进程**页面，会列出可注入的 `QQ` 进程（形如「N 进程 · M 可注入」）；
3. 选择你的 QQ 进程执行**进程注入**，成功后该 QQ 账号显示为「在线 / 已接入」；
4. SnowLuma 会按 `config\onebot.json` 里的 `wsClients` 自动连到 AstrBot，无需再填地址。

> 若注入失败：优先尝试**以管理员身份运行** `start-snowluma.bat`；
> 关闭并重开 QQ 再试；QQ 大版本更新后可能需要等待 SnowLuma 跟进适配。

### 确认 OneBot 已连上 AstrBot

看 AstrBot 的控制台窗口（或 `AstrBot\data\logs\astrbot.log`），出现这行即成功：

```
[INFO] [aiocqhttp.aiocqhttp_platform_adapter:107]: aiocqhttp(OneBot v11) 适配器已连接。
```

也可以在 AstrBot 面板「平台 / 机器人」页看到 `qq_onebot` 平台处于运行状态。

### 配置大模型

1. AstrBot 面板左侧进入**服务提供商 / 模型提供商**；
2. 点击**新增**，选择服务类型（OpenAI 兼容 / DeepSeek / Gemini / Ollama …）；
3. 填入 API Key、接口地址、模型名，保存并**启用**；
4. 可随时在面板的「对话」页先测试模型是否可用。

> 未配置模型时，机器人仍能响应 `/help`、`/reset` 等内置命令，
> 但不会进行 AI 对话——这是判断「链路是否通」的最快方式。

### 在 QQ 里测试

用另一个 QQ 号（或让朋友）给机器人发消息：

| 发送内容 | 预期结果 |
| --- | --- |
| `/help` | 返回 AstrBot 内置命令列表 |
| `/你好` | 由大模型回复（需先完成 5.6） |
| `#sl` | SnowLuma 的状态命令，直接返回连接状态 |

注意：AstrBot 默认**唤醒前缀为 `/`**，不带前缀的消息不会触发 AI 回复。
若想让机器人对私聊“随便聊”，可在 AstrBot 面板 → 配置 → 其他 → **唤醒前缀** 中清空。

---



## 附录 A：本次部署的实际做法

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
