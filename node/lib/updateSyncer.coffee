http = require('http')
fs = require('fs')
DateFormatter = require('./dateFormatter').DateFormatter
RRD = require('./rrd/lib/rrd').RRD

class UpdateSyncer
  constructor: (@host, @port, @app) ->
    setInterval () =>
      this.checkForUpdates()
    , 1000 * 5

  checkForUpdates: () =>
    timestamp = new DateFormatter(new Date).filenameTimestamp()
    path = "./db"
    newFilenameBase = "#{@app}-#{timestamp}"
    file = fs.createWriteStream("#{path}/#{newFilenameBase}.xml")

    console.log "Checking for updates from #{@host}:#{@port} for #{@app} (timestamp: #{timestamp})"
    request = http.request {
      host: @host,
      port: @port,
      path: "/#{@app}/rrd.xml",
      method: "GET"
    }, (response) =>
      console.log(" - #{response.statusCode}")
      response.setEncoding('utf8')
      response.on('data', (chunk) ->
        file.write(chunk)
      )
      response.on('end', () =>
        file.end()
        this.importRRD(path, newFilenameBase)
      )
    request.end()

  importRRD: (path, filenameBase) =>
    RRD.restore "#{path}/#{filenameBase}.xml", "#{path}/#{filenameBase}.rrd", (err, i, out) =>
      symlink = "#{path}/#{@app}.rrd"
      fs.unlink "#{path}/#{filenameBase}.xml", (err, stdin, stdout) ->
        console.log(stdout)
      fs.unlink symlink, () ->
        fs.symlink "#{filenameBase}.rrd", symlink, (err) ->
          console.log(err)

exports.UpdateSyncer = UpdateSyncer
