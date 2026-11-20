#! /usr/bin/env python3

# example #1 - WiFi connection at boot
#from pynq.lib import Wifi
#
#port = Wifi()
#port.connect('your_ssid', 'your_password', auto=True)

# example #2 - Change hostname
#import subprocess
#subprocess.call('pynq_hostname.sh aNewHostName'.split())

# example #3 - blink LEDs (PYNQ-Z1, PYNQ-Z2, ZCU104)
#from pynq import Overlay
#from time import sleep
#
#ol = Overlay('base.bit')
#leds = ol.leds
#
#for _ in range(8):
#    leds[0:4].off()
#    sleep(0.2)
#    leds[0:4].on()
#    sleep(0.2)#!/usr/local/share/pynq-venv/bin/python

from pynq.overlays.base import BaseOverlay
from time import sleep

ol = BaseOverlay('base.bit')
leds = ol.leds

for _ in range(8):
    leds[0:4].off()
    sleep(0.2)
    leds[0:4].on()
    sleep(0.2)

#  Runs SALSA only when /boot/RUN_SALSA exists, so normal boots are unaffected.
# Delete RUN_SALSA (or rename it) to switch the autorun off.
import os
import subprocess

if os.path.exists("/boot/RUN_SALSA") and os.path.exists("/boot/startup.sh"):
    with open("/boot/startup.sh", "rb") as f:
        script = f.read().replace(b"\r\n", b"\n").decode()      # strip Windows line endings
    subprocess.call(["bash", "-c", script])