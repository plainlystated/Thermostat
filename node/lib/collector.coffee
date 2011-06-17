serial_dev = '/dev/cu.usbserial-10KP0043'

spawn = require('child_process').spawn
# serial = spawn('python', ['serial_proxy.py', serial_dev])

MemcacheClient = require('./memcache').Client

class Collector
  constructor: (@port) ->
    @memcache = setupMemcachedClient()
    this.writeToMemcache(1)
    @memcache.disconnect

    # this.collectData()

  # collectData: () ->
  #   serial.stdout.on('data', (data) ->
  #     data = data.toString()
  #     console.log(data)

  #     parsedLine = parseTemperatureLine(data)
  #     if parsedLine.currentTemp?
  #       console.log(" - #{parsedLine.currentTemp}, #{parsedLine.state}")
  #   )

  #   serial.stderr.on('data', (data) ->
  #     console.log('stderr: ' + data)
  #   )

  writeToMemcache: (data) ->
    @memcache.set('key1', {value: 1})
    @memcache.get('key1', (err, result) ->
      for key in result
        console.log("#{key}")
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

exports.Collector = Collector
