========================================================================
  Windows 11 Local Whisper Preflight & Model Fit Checker (v1.2)
========================================================================

Just unzip this folder and double-click RUN_PREFLIGHT.bat - 100%
read-only, no Python required.

- You can press Enter to save the report in this toolkit folder, or paste
  another folder path. Quoted paths and trailing backslashes are handled
  correctly by the launcher.
- The script is saved as UTF-8 with a BOM and uses ASCII punctuation so
  Windows PowerShell 5.1 does not garble the recommended-model text.

------------------------------------------------------------------------
WINDOWS SMARTSCREEN UNBLOCK INSTRUCTIONS
------------------------------------------------------------------------
Because .bat and .ps1 files downloaded from the internet are unsigned,
Windows SmartScreen may show "Windows protected your PC" on first run:
  Option A: Click "More info" -> "Run anyway".
  Option B: Right-click the downloaded .zip file BEFORE extracting ->
            Properties -> check "Unblock" -> Apply / OK -> then extract.
