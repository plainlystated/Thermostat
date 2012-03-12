express = require('express')
UpdateSyncer = require('./updateSyncer').UpdateSyncer
fs = require('fs')
RRD = require('./rrd/rrd').RRD
DateFormatter = require('./dateFormatter').DateFormatter

class Server
  constructor: (@apps, fetchUpdates = true) ->
    this.startServer()
    if fetchUpdates
      for name, app of @apps
        new UpdateSyncer(rrdSourceHost(), 3001, app.viewData.slug)

  startServer: () ->
    @app = module.exports = express.createServer()

    publicDir = __dirname + '/../public'
    @app.configure(() =>
      @app.use express.logger()
      @app.set('views', __dirname + '/../views')
      @app.set('view engine', 'ejs')
      @app.use(express.bodyParser())
      @app.use(express.methodOverride())
      @app.use(@app.router)
      @app.use express.compiler(
        src: __dirname + '/../coffee',
        dest: publicDir,
        enable: ['coffeescript']
      )
      @app.use(express.static(publicDir))
    )

    @app.configure('development', () =>
      @app.use(express.errorHandler({ dumpExceptions: true, showStack: true }))
    )

    @app.configure('production', () =>
      @app.use(express.errorHandler())
    )

    @app.get('/', (req, res) =>
      app = @apps[req.headers.host.replace(/\..*$/, '')]
      if app
        res.render('index', { view: app.viewData })
      else
        res.send('Not Found', 404)
    )

    @app.get '/:appName/data/:scope', (req, res) =>
      app = @apps[req.params.appName]
      start = this.lookupStartDate(req.params.scope)
      if app && start
        flotData app, DateFormatter.rrd(start), (data) ->
          res.send(data)
      else
        res.send('Not found', 404)

    flotData = (app, start, cb) ->
      end = DateFormatter.rrd(new Date())
      new RRD(app.rrdFilepath).fetch start, end, (err, records) ->
        data = for lineOptions in [
          { label: 'target_temp', color: 1},
          { label: 'temperature', color: 0}
        ]
          lineOptions['data'] = for record in records
            timestampWithTimezoneOffset = parseInt(record.timestamp) - 60 * (new Date).getTimezoneOffset()
            [timestampWithTimezoneOffset * 1000, record[lineOptions.label]]
          lineOptions
        cb(data)

    @app.listen(3000)
    console.log("Express server listening on port %d", @app.address().port)

  rrdSourceHost = () ->
    fs.readFileSync('./config/rrdSource').toString().replace(/(\n|\r)+$/, '')

  lookupStartDate: (scope) ->
    switch scope
      when "day"   then new Date(new Date - (1000 * 60 * 60 * 24))
      when "week"  then new Date(new Date - (1000 * 60 * 60 * 24 * 7))
      when "month" then new Date(new Date - (1000 * 60 * 60 * 24 * 31))
      else null


exports.Server = Server
