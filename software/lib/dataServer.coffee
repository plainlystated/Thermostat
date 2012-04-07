RRD = require('./rrd').RRD
http = require('http')

class DataServer
  constructor: (@apps, port) ->
    http.createServer((req, res) =>
      if app = this.lookupApp(req)
        rrd = new RRD(app.rrdFilepath)
        res.writeHead(200, {'Content-Type': 'text/xml'})
        rrd.dump (err, xml) ->
          res.end xml
      else
        res.writeHead(404, {'Content-Type': 'text/xml'})
        res.end()
    ).listen(port, "0.0.0.0")
    console.log("Listening for RRD data requests on port #{port}")

  lookupApp: (req) ->
    @apps[req.url.substr(1)]

exports.DataServer = DataServer
