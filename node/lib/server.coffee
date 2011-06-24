express = require('express')
UpdateSyncer = require('./updateSyncer').UpdateSyncer
fs = require('fs')

class Server
  constructor: (rrdFile, port) ->
    views = {
      hotOrNot: {
        title: "Hot Or Not",
        tagLine: "Keeping you cool since 2011",
        slug: "hot-or-not"
      }
    }
    this.startServer(views)
    new UpdateSyncer(rrdSourceHost(), 80, views.hotOrNot.slug)

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

    @app.get('/hot-or-not', (req, res) =>
      res.render('index', { view: views['hotOrNot'] })
    )

    @app.get('/hot-or-not/data/month', (req, res) =>
      demoData = [[1308320046000, -170.418101328087], [1308320046001, -73.1844564682735], [1308320046002, 31.6753566158387], [1308320046003, 119.376291195278], [1308320046004, 140.983767830792], [1308320046005, 144.796851942941], [1308320046006, 98.4043285784555], [1308320046007, 13.2454500737826], [1308320046008, -92.2498770290211], [1308320046009, -175.502213477619], [1308320046010, -193.296606000984], [1308320046011, -195.203148057059], [1308320046012, -144.362026561731], [1308320046013, -54.7545499262174], [1308320046014, 49.4697491392032], [1308320046015, 127.002459419577], [1308320046016, 142.254795868175], [1308320046017, 144.16133792425], [1308320046018, 87.6005902606985]]
      setTimeout(() ->
        res.send(demoData)
      , 200
      )
    )

    @app.get('/', (req, res) ->
      res.redirect('/hot-or-not')
    )

    @app.listen(3000)
    console.log("Express server listening on port %d", @app.address().port)

  rrdSourceHost = () ->
    fs.readFileSync('./config/rrdSource').toString().replace(/(\n|\r)+$/, '')

exports.Server = Server
