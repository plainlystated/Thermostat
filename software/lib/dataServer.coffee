RRD = require('./rrd').RRD
http = require('http')

class DataServer
  constructor: (app, port) ->
    http.createServer((req, res) =>
      console.log("serving request")
      rrd = new RRD(app.rrdFilepath)
      res.writeHead(200, {'Content-Type': 'text/xml'})
      rrd.dump (err, xml) ->
        res.end xml
    ).listen(port, "0.0.0.0")
    console.log("Listening for RRD data requests on port #{port}")

exports.DataServer = DataServer
