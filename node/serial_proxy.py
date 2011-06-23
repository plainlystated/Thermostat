#!/usr/bin/env python
import serial, sys, string

# workaround for nodejs serial library weirdness

if len(sys.argv) == 1:
    sys.exit(["Required arg: serial dev (eg /dev/ttyUSB0)"])

serial_dev = sys.argv[1]
serial = serial.Serial(serial_dev, 9600)
serial.open()

# make stdin a non-blocking file
import fcntl
import os
fd = sys.stdin.fileno()
fl = fcntl.fcntl(fd, fcntl.F_GETFL)
fcntl.fcntl(fd, fcntl.F_SETFL, fl | os.O_NONBLOCK)

# user input handling thread
while True:
  sys.stdout.write(serial.readline())
  sys.stdout.flush()
  try: input = sys.stdin.readline()
  except: continue
  serial.write(input.rstrip('\n'))
