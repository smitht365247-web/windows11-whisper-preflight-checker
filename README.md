# Windows 11 Local Whisper Preflight & Model Fit Checker (Free, Portable)

A lightweight, **100% read-only** Windows 10/11 preflight utility that checks your **system RAM, 64-bit GPU VRAM (NVIDIA / AMD / Intel Arc), FFmpeg availability, and local Whisper CLI binaries**, then recommends the best offline Whisper model tier and acceleration backend—no Python or coding required.

## What It Checks (Zero System Changes)
- **System RAM & 64-Bit VRAM:** Uses `nvidia-smi` first, then 64-bit Registry `HardwareInformation.qwMemorySize` (avoids the Windows 4 GB `AdapterRAM` cap and excludes shared iGPU RAM).
- **FFmpeg & Whisper Binaries:** Checks both `PATH` and `.\bin` for `ffmpeg.exe`, `whisper-cli.exe`, `main.exe`, `faster-whisper-xxl.exe`, and `whisper.exe`.
- **Model & Backend Recommendation:** Recommends `base.en`/`small`, `small`/`medium`, or `large-v3-turbo` plus CUDA vs. portable CPU/Vulkan `whisper.cpp` backend, saved to `whisper_preflight_*.txt`.

## Quick Start
1. Click **Code -> Download ZIP** (or grab the free pre-packaged ZIP on [Gumroad](https://smitht365.gumroad.com/l/inttob)).
2. Extract the ZIP folder to your PC (e.g., `C:\Tools\Win11-Whisper-Preflight-Checker`).
3. Double-click `RUN_PREFLIGHT.bat`, press **Enter** (or paste a custom output folder), and review your preflight report.

## Windows SmartScreen Unblock Instructions
Because `.bat` and `.ps1` files downloaded from the internet are unsigned, Windows SmartScreen may show *"Windows protected your PC"* on the first run:
- Click **More info** -> **Run anyway**, **OR**
- Right-click the downloaded `.zip` file **before extracting** -> **Properties** -> check **Unblock** -> **Apply / OK**, then extract.

## Want 100% Offline Batch Transcription, Subtitles & Markdown Notes?
Upgrade to the **[Windows 11 Local Whisper Batch Transcriber & Subtitle Studio ($19 on Gumroad)](https://smitht365.gumroad.com/l/hyijza)** — portable Windows 10/11 studio featuring:
- **100% Offline Batch Audio/Video Transcription** (`.txt`, `.srt`, and `.vtt` subtitle exports)
- **Automatic 16kHz Mono WAV Converter** (via FFmpeg for `whisper.cpp`)
- **Markdown Study & Show-Notes Compiler** (clean compiled notes ready for Obsidian/Notion)
- **Zero Python or Cloud Uploads**
