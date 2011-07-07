express = require('express')
UpdateSyncer = require('./updateSyncer').UpdateSyncer
fs = require('fs')
RRD = require('./rrd/rrd').RRD
DateFormatter = require('./dateFormatter').DateFormatter

class Server
  constructor: (rrdFile, port, fetchUpdates = true) ->
    views = {
      hotOrNot: {
        title: "Hot Or Not",
        tagLine: "Keeping you cool since 2011",
        slug: "hot-or-not"
      }
    }
    this.startServer(views)
    fetchUpdates ? new UpdateSyncer(rrdSourceHost(), 80, views.hotOrNot.slug)

  startServer: (views) ->
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
      res.render('index', { view: views['hotOrNot'] })
    )

    @app.get '/hot-or-not/data/day', (req, res) =>
      start = DateFormatter.rrd(new Date(new Date - (1000 * 60 * 60 * 24)))
      flotData start, (data) ->
        res.send(data)

    @app.get '/hot-or-not/data/week', (req, res) =>
      start = DateFormatter.rrd(new Date(new Date - (1000 * 60 * 60 * 24 * 7)))
      flotData start, (data) ->
        res.send(data)

    @app.get '/hot-or-not/data/month', (req, res) =>
      start = DateFormatter.rrd(new Date(new Date - (1000 * 60 * 60 * 24 * 31)))
      flotData start, (data) ->
        res.send(data)


    flotData = (start, cb) ->
      end = DateFormatter.rrd(new Date())
      new RRD("./db/hot-or-not.rrd").fetch start, end, (records) ->
        data = for dataSource in ['temperature', 'target_temp']
          line = { label: dataSource }
          line['data'] = for record in records
            timestampWithTimezoneOffset = parseInt(record.timestamp) - 60 * (new Date).getTimezoneOffset()
            [timestampWithTimezoneOffset * 1000, record[dataSource]]
          line
        cb(data)

    @app.listen(3000)
    console.log("Express server listening on port %d", @app.address().port)

  rrdSourceHost = () ->
    fs.readFileSync('./config/rrdSource').toString().replace(/(\n|\r)+$/, '')

exports.Server = Server
