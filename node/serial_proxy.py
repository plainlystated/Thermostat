#!/usr/bin/env python
import serial, sys, string

# workaround for nodejs serial library weirdness

if len(sys.argv) == 1:
    sys.exit(["Required arg: serial dev (eg /dev/ttyUSB0)"])

serial_dev = sys.argv[1]
serial = serial.Serial(serial_dev, 9600)
serial.open()

while True:
    sys.stdout.write(serial.readline())
    sys.stdout.flush()
