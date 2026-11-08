#!/usr/bin/env python3
"""Export the approved artwork; install Android adaptive/monochrome vectors."""
from pathlib import Path
import re
import shutil
import subprocess

ROOT = Path(__file__).resolve().parent


def main():
    subprocess.run(["dart", "run", "flutter_launcher_icons"], cwd=ROOT, check=True)
    resources = ROOT / "android/app/src/main/res"
    drawable = resources / "drawable/ic_launcher_foreground.xml"
    drawable.parent.mkdir(parents=True, exist_ok=True)
    shutil.copyfile(ROOT / "assets/icon/ic_launcher_foreground.xml", drawable)
    # Remove obsolete density variants so Android always resolves the vector.
    for legacy in resources.glob("drawable-*/ic_launcher_foreground.png"):
        legacy.unlink()
    adaptive = resources / "mipmap-anydpi-v26/ic_launcher.xml"
    adaptive.parent.mkdir(parents=True, exist_ok=True)
    adaptive.write_text('''<?xml version="1.0" encoding="utf-8"?>
<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">
  <background android:drawable="@color/ic_launcher_background"/>
  <foreground>
    <inset android:drawable="@drawable/ic_launcher_foreground" android:inset="16%"/>
  </foreground>
  <monochrome>
    <inset android:drawable="@drawable/ic_launcher_foreground" android:inset="16%"/>
  </monochrome>
</adaptive-icon>
''')
    colors = resources / "values/colors.xml"
    colors.write_text(re.sub(r'(<color name="ic_launcher_background">)[^<]+',
                             r'\g<1>#087BE8', colors.read_text()))
    print("Launcher sizes and Android vector layers installed.")


if __name__ == "__main__":
    main()
