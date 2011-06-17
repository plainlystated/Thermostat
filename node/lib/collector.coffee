spawn = require('child_process').spawn
RRD = require('./rrd/lib/rrd').RRD
fs = require('fs')

class Collector
  constructor: (@rrdFile, @port) ->
    this.collectData()

  collectData: () =>
    serial = spawn('python', ['serial_proxy.py', usbDev()])

    @rrd = new RRD(@rrdFile)
    serial.stdout.on('data', (data) ->
      data = data.toString()
      console.log(data)
      parsedLine = parseTemperatureLine(data)
      if parsedLine.currentTemp?
        console.log(" - #{parsedLine.currentTemp}, #{parsedLine.state}")
        rrd.update new Date, parsedLine.currentTemp, parsedLine.targetTemp, parsedLine.state, printError
    )

    serial.stderr.on('data', (data) ->
      console.log('stderr: ' + data)
    )

  parseTemperatureLine = (string) ->
    result = string.split(" ")
    currentTemp = result[0]
    targetTemp = result[1]
    state = result[2]

    if currentTemp.match("^[0-9.]*$")
      console.log state
      if state.match(/heat-on/)
        s = 1
      else if state.match(/ac-on/)
        s = -1
      else
        s = 0
      return { currentTemp: currentTemp, targetTemp: targetTemp, state: s }
    else
      return {}

  printError = (err) ->
    console.log(" - #{err}") if err?

  setupMemcachedClient = () ->
    client = new MemcacheClient()
    client.on('connect', () ->
      console.log('connected to memcached')
    )
    client.on('close', () ->
      console.log('disconnected from memcached')
    )
    client.on('timeout', () ->
      console.log('timeout connecting to memcached')
    )
    client.on('error', (e) ->
      console.log("memcached error: #{e}")
    )
    client.connect()
    return client

  usbDev = () ->
    return fs.readFileSync('./config/usb_dev')

exports.Collector = Collector
