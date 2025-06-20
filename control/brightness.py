#!/usr/bin/env python3
import os
import sys

# Detect the backlight device
def find_backlight_device():
    base_path = '/sys/class/backlight'
    try:
        devices = os.listdir(base_path)
        if not devices:
            print("No backlight device found.")
            sys.exit(1)
        return os.path.join(base_path, devices[0])
    except FileNotFoundError:
        print("Backlight control not supported on this system.")
        sys.exit(1)

def get_brightness_info(dev_path):
    with open(os.path.join(dev_path, 'max_brightness')) as f:
        max_brightness = int(f.read().strip())
    with open(os.path.join(dev_path, 'brightness')) as f:
        current_brightness = int(f.read().strip())
    return current_brightness, max_brightness

def set_brightness(dev_path, value):
    brightness_path = os.path.join(dev_path, 'brightness')
    try:
        with open(brightness_path, 'w') as f:
            f.write(str(value))
    except PermissionError:
        print("Permission denied. Try running as root (sudo).")
        sys.exit(1)

def main():
    if len(sys.argv) != 2:
        print("Usage: brightness.py <value|+10|-10>")
        sys.exit(1)

    dev_path = find_backlight_device()
    current, max_brightness = get_brightness_info(dev_path)
    arg = sys.argv[1]

    try:
        if arg.startswith('+') or arg.startswith('-'):
            new_brightness = current + int(arg)
        else:
            new_brightness = int(arg)

        new_brightness = max(0, min(new_brightness, max_brightness))
        set_brightness(dev_path, new_brightness)
        print(f"Brightness set to {new_brightness}/{max_brightness}")
    except ValueError:
        print("Invalid brightness value.")
        sys.exit(1)

if __name__ == '__main__':
    main()

