spawn = require('child_process').spawn
RRD = require('../rrd/rrd').RRD
fs = require('fs')
GoogleCalendar = require('./googleCalendar').GoogleCalendar

class Collector
  constructor: (@rrdFile) ->
    @rrd = new RRD(rrdFile)
    this.collectData(@rrd)
    @googleCalendar = new GoogleCalendar

  collectData: (rrd) =>
    serial = spawn('python', ['serial_proxy.py', usbDev()])
    serial.stdout.on('data', (data) ->
      data = data.toString()
      console.log(data)
      parsedLine = parseTemperatureLine(data)
      if parsedLine.currentTemp?
        console.log(" - #{parsedLine.currentTemp}, #{parsedLine.state}")
        rrd.update new Date, [parsedLine.currentTemp, parsedLine.targetTemp, parsedLine.state], printError
    )

    serial.stderr.on('data', (data) ->
      console.log('stderr: ' + data)
    )

    setInterval () =>
      @googleCalendar.getCurrent (current) ->
        console.log("updating with #{current.temperature}")
        serial.stdin.write("#{String.fromCharCode(current.temperature)}\n")
    , 10000


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

  usbDev = () ->
    fs.readFileSync('./config/usbDev').toString().replace(/(\n|\r)+$/, '')

exports.Collector = Collector
