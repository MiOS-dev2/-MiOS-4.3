@echo off
echo Starting QEMU with floppy.img...
"C:\Program Files\qemu\qemu-system-x86_64.exe" -drive format=raw,file="MiOS.img" -monitor stdio
pause