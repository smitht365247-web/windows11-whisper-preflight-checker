<#
.SYNOPSIS
    Hardened v1.0: Read-only audit of Windows 10/11 RAM, 64-bit GPU VRAM (NVIDIA / AMD / Intel Arc),
    local Whisper CLI binaries (whisper-cli / main / faster-whisper / whisper), FFmpeg availability,
    and recommended offline Whisper model tier.
#>
param(
    [string]$OutputFolder = $PSScriptRoot
)

if ($OutputFolder -match '^[A-Za-z]:$') { $OutputFolder += '\' }
if (-not (Test-Path -LiteralPath $OutputFolder)) {
    New-Item -ItemType Directory -Path $OutputFolder -Force | Out-Null
}
$OutputFolder = (Resolve-Path -LiteralPath $OutputFolder).Path

Write-Host "Checking RAM, 64-bit VRAM, FFmpeg, and local Whisper binaries..." -ForegroundColor Cyan

# 1. System RAM
$cs = Get-CimInstance -ClassName Win32_ComputerSystem
$totalRamGB = [math]::Round($cs.TotalPhysicalMemory / 1GB, 2)

# 2. Layered 64-bit VRAM detection (avoids 32-bit AdapterRAM 4 GB cap & excludes shared iGPU RAM)
$gpuSummary = @()
$maxVramGB = 0.0
$hasNvidia = $false

$nvidiaSmi = Get-Command nvidia-smi -ErrorAction SilentlyContinue
if ($nvidiaSmi) {
    try {
        $smiLines = & nvidia-smi --query-gpu=name,memory.total --format=csv,noheader,nounits 2>$null
        foreach ($line in $smiLines) {
            if ([string]::IsNullOrWhiteSpace($line)) { continue }
            $parts = $line -split ","
            $gName = $parts[0].Trim()
            $vramMB = 0.0
            [double]::TryParse($parts[1].Trim(), [ref]$vramMB) | Out-Null
            $vramGB = [math]::Round($vramMB / 1024.0, 2)
            if ($vramGB -gt $maxVramGB) { $maxVramGB = $vramGB }
            $hasNvidia = $true
            $gpuSummary += "$gName ($vramGB GB VRAM via nvidia-smi)"
        }
    } catch { }
}

if ($gpuSummary.Count -eq 0) {
    $regBase = "HKLM:\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}"
    $adapters = Get-CimInstance -ClassName Win32_VideoController -ErrorAction SilentlyContinue
    foreach ($ad in $adapters) {
        $name = $ad.Name
        $qwGB = 0.0
        if ($ad.PNPDeviceID) {
            $subKeys = Get-ChildItem -Path $regBase -ErrorAction SilentlyContinue | Where-Object { $_.PSChildName -match '^\d{4}$' }
            foreach ($sk in $subKeys) {
                $props = Get-ItemProperty -Path $sk.PSPath -ErrorAction SilentlyContinue
                $mId = [string]$props.MatchingDeviceId
                $dId = [string]$ad.PNPDeviceID
                if ($mId -and ($dId -like "*$($mId.Split('\')[-1])*")) {
                    if ($null -ne $props.'HardwareInformation.qwMemorySize') {
                        $qwGB = [math]::Round(([double]$props.'HardwareInformation.qwMemorySize') / 1GB, 2)
                        break
                    }
                }
            }
        }
        if ($qwGB -gt 0) {
            if ($qwGB -gt $maxVramGB) { $maxVramGB = $qwGB }
            $gpuSummary += "$name ($qwGB GB dedicated VRAM via Registry)"
        } else {
            $gpuSummary += "$name (dedicated VRAM not reported by driver; shared iGPU RAM excluded)"
        }
    }
}

# 3. FFmpeg & Whisper engine detection (PATH + local toolkit subfolders)
$ffmpegCmd = Get-Command ffmpeg -ErrorAction SilentlyContinue
$ffmpegPath = if ($ffmpegCmd) { $ffmpegCmd.Source } else {
    $localFfmpeg = Join-Path $PSScriptRoot "bin\ffmpeg.exe"
    if (Test-Path -LiteralPath $localFfmpeg) { $localFfmpeg } else { $null }
}

$whisperBins = @("whisper-cli.exe", "main.exe", "faster-whisper-xxl.exe", "whisper.exe")
$foundEngines = @()
foreach ($b in $whisperBins) {
    $cmd = Get-Command $b -ErrorAction SilentlyContinue
    if ($cmd) {
        $foundEngines += "$b ($($cmd.Source))"
    } else {
        $localBin = Join-Path $PSScriptRoot ("bin\" + $b)
        if (Test-Path -LiteralPath $localBin) {
            $foundEngines += "$b ($localBin)"
        }
    }
}

# 4. Model tier recommendation
$recModel = "base.en or small (~150-500 MB) — fast CPU/laptop tier"
$recBackend = if ($hasNvidia) { "CUDA GPU acceleration available" } else { "CPU / Vulkan whisper.cpp portable binary (zero Python required)" }

if ($maxVramGB -ge 8) {
    $recModel = "large-v3-turbo or medium (~1.5-3.1 GB) — full GPU speed"
} elseif ($maxVramGB -ge 4 -or $totalRamGB -ge 16) {
    $recModel = "small or medium (~500 MB-1.5 GB) — balanced speed & accuracy"
}

$reportPath = Join-Path $OutputFolder ("whisper_preflight_{0}.txt" -f (Get-Date -Format "yyyyMMdd_HHmmss"))
$lines = @(
    "WINDOWS 11 LOCAL WHISPER PREFLIGHT & MODEL FIT REPORT (v1.0)",
    "Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')",
    "------------------------------------------------------------",
    "System RAM:          $totalRamGB GB",
    "GPU Summary:         $($gpuSummary -join ' | ')",
    "Max Dedicated VRAM:  $maxVramGB GB",
    "FFmpeg Detected:     $(if ($ffmpegPath) { $ffmpegPath } else { 'Not found (place ffmpeg.exe in .\bin or install via winget install Gyan.FFmpeg)' })",
    "Whisper Engines:     $(if ($foundEngines.Count -gt 0) { $foundEngines -join '; ' } else { 'None found yet (drop whisper-cli.exe + ggml model in .\bin or add to PATH)' })",
    "------------------------------------------------------------",
    "Recommended Model:   $recModel",
    "Recommended Backend: $recBackend"
)

$lines | Set-Content -LiteralPath $reportPath -Encoding UTF8
$lines | ForEach-Object { Write-Host $_ }
Write-Host ""
Write-Host "Preflight report saved to: $reportPath" -ForegroundColor Green
