#!/usr/bin/env python3
"""
Cross-Platform Desktop Notification Utility
Supports macOS, Linux, and Windows
"""
import platform
import os
import sys
import subprocess


def notify(title, message):
    """Send a desktop notification."""
    system = platform.system()

    try:
        if system == 'Darwin':  # macOS
            script = f'display notification "{message}" with title "{title}"'
            subprocess.run(['osascript', '-e', script],
                         check=False,
                         capture_output=True)

        elif system == 'Linux':
            # Try notify-send (most Linux desktops)
            subprocess.run(['notify-send', title, message],
                         check=False,
                         capture_output=True)

        elif system == 'Windows':
            # Try Windows 10+ toast notifications
            ps_script = f"New-BurntToastNotification -Text '{title}', '{message}'"
            subprocess.run(['powershell', '-Command', ps_script],
                         check=False,
                         capture_output=True)

    except Exception:
        # Silently fail if notifications aren't available
        pass


if __name__ == '__main__':
    if len(sys.argv) != 3:
        print("Usage: notify.py <title> <message>", file=sys.stderr)
        sys.exit(1)

    notify(sys.argv[1], sys.argv[2])
