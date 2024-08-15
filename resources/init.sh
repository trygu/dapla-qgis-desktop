#!/bin/bash

# Create a copy of vnc.html to index.html.
cp /usr/share/novnc/vnc_lite.html /usr/share/novnc/index.html

# Start X Virtual Framebuffer
Xvfb :1 -screen 0 1920x1080x24 &
sleep 5

# Make it pretty
export X11_XFT_ANTIALIAS=1
export X11_XFT_RGBA=rgb
export X11_XFT_HINTING=1
export X11_XFT_HINTSTYLE=hintmedium
 
export PYTHONPATH=/home/dapla/.miniconda3/lib/python3.12/site-packages:$PYTHONPATH
export PATH="~/.miniconda3/bin:$PATH"

# Source the Conda setup script to set up the shell for Conda
source ~/.miniconda3/etc/profile.d/conda.sh

# Activate your environment
conda activate base

# Disable access control for X11
xhost +

# Start Openbox
openbox-session &

# Start VNC server
x11vnc -forever -nopw -create -display :1 &

# Start noVNC
/usr/share/novnc/utils/novnc_proxy --vnc localhost:5900 --listen 6080 &

# Start QGis from the conda installation
conda run -n base --no-capture-output ~/.miniconda3/bin/qgis
