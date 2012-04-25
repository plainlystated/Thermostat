spawn = require('child_process').spawn
RRD = require('./rrd/rrd').RRD
fs = require('fs')
GoogleCalendar = require('./googleCalendar').GoogleCalendar

class Collector
  constructor: (@rrdFile) ->
    @rrd = this.rrd(rrdFile)
    this.collectData(@rrd)
    @calendar = this.googleCalendar()

  rrd: (filename) ->
    new RRD(filename)

  googleCalendar: () ->
    new GoogleCalendar

  serialProxy: () ->
    spawn('python', ['serial_proxy.py', usbDev()])

  collectData: (rrd) =>
    collector = this
    serial = this.serialProxy()
    serial.stdout.on 'data', (data) ->
      data = data.toString()
      parsedLine = parseTemperatureLine(data)
      if parsedLine.currentTemp?
        collector.log(" - #{parsedLine.currentTemp}, #{parsedLine.state}")
        rrd.update new Date, [parsedLine.currentTemp, parsedLine.targetTemp, parsedLine.state], printError

    serial.stderr.on('data', (data) ->
      collector.log('stderr: ' + data)
    )

    setInterval () =>
      @calendar.getCurrent (current) ->
        serial.stdin.write("#{current.temperature}\n")
    , 1000

  log: (msg) ->
    console.log msg

  parseTemperatureLine = (string) ->
    result = string.split(" ")
    currentTemp = result[0]
    targetTemp = result[1]
    state = result[2]

    if currentTemp.match("^[0-9.]*$")
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
    this.log(" - #{err}") if err?

  usbDev = () ->
    fs.readFileSync('./config/usbDev').toString().replace(/(\n|\r)+$/, '')

exports.Collector = Collector
