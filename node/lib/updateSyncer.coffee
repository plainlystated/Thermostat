http = require('http')
fs = require('fs')

class UpdateSyncer
  constructor: (@host, @port, @app) ->
    @client = http.createClient(@port, @host)
    setInterval () =>
      this.checkForUpdates()
    , 1000 * 5

  checkForUpdates: () ->
    timestamp = formatTimestamp(new Date)
    newFilenameBase = "./db/thermostat-#{timestamp}"
    file = fs.createWriteStream("#{newFilenameBase}.xml")

    console.log "Checking for updates from #{@host}:#{@port} (timestamp: #{timestamp})"
    request = @client.request('GET', "/#{@app}/rrd.xml", {})
    request.end()
    request.on('response', (response) ->
      console.log(" - #{response.statusCode}")
      response.setEncoding('utf8')
      response.on('data', (chunk) ->
        file.write(chunk)
      )
      response.on('end', () ->
        file.end()
        this.importRRD(newFilenameBase)
      )
    )

  importRRD: (filenameBase) ->
    RD.restore("#{filenameBase}.xml", "#{filenameBase}.rrd", () ->
      fs.symlink("#{filenameBase}.rrd", "../db/thermostat-synced.rrd")
    )

  formatTimestamp = (date) ->
    year = date.getFullYear()
    month = date.getMonth()
    day = date.getDate()
    hour = date.getHours()
    minute = date.getMinutes()
    second = date.getSeconds()

    if month < 10
      month = "0#{month}"
    if day < 10
      day = "0#{day}"
    if hour < 10
      hour = "0#{hour}"
    if minute < 10
      minute = "0#{minute}"
    if second < 10
      second = "0#{second}"
    timestamp = "#{year}-#{month}-#{day}.#{hour}#{minute}#{second}"

exports.UpdateSyncer = UpdateSyncer
