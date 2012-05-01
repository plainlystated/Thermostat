spawn = require('child_process').spawn
RRD = require('./rrd/rrd').RRD
fs = require('fs')
GoogleCalendar = require('./googleCalendar').GoogleCalendar

class Collector
  constructor: (@rrdFile) ->
    @rrd = this.rrd(rrdFile)
    this.collectData(@rrd)

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
        collector.log(" - #{parsedLine.currentTemp}")
        rrd.update new Date, [parsedLine.currentTemp], printError

    serial.stderr.on('data', (data) ->
      collector.log('stderr: ' + data)
    )

  log: (msg) ->
    console.log msg

  parseTemperatureLine = (currentTemp) ->
    if currentTemp.match("^[0-9.]*$")
      return { currentTemp: currentTemp }
    else
      return {}

  printError = (err) ->
    console.log(" - #{err}") if err?

  usbDev = () ->
    fs.readFileSync('./config/usbDev').toString().replace(/(\n|\r)+$/, '')

exports.Collector = Collector
