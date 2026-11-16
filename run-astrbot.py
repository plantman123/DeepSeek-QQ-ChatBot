# AstrBot 启动器
# 用法： tools\\Python312\\python.exe run-astrbot.py [main.py 的原生参数]


import os
import runpy
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent
ASTRBOT_DIR = ROOT / "AstrBot"
MAIN = ASTRBOT_DIR / "main.py"

if not MAIN.is_file():
    sys.exit(f"[run-astrbot] 找不到 AstrBot 入口：{MAIN}")

sys.path.insert(0, str(ASTRBOT_DIR))
os.chdir(ASTRBOT_DIR)
runpy.run_path(str(MAIN), run_name="__main__")
