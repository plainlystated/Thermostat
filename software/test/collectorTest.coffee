Collector = require('../lib/collector').Collector
EventEmitter = require('events').EventEmitter
sinon = require('sinon')
TestHelper = require('./testHelper').TestHelper
should = require('should')
Buffer = require('buffer').Buffer

CollectorTestHelper =
  setupFakes: (googleCalendarTemp) ->
    fakeProxy =
      stdout: new EventEmitter()
      stderr: new EventEmitter()
      stdin: new Buffer(new Array(256))

    fakeRRD =
      update: sinon.mock()

    Collector.prototype.rrd = (filename) ->
      fakeRRD
    Collector.prototype.serialProxy = () ->
      fakeProxy
    Collector.prototype.log = (msg) ->

    fakeGoogleCalendar =
      getCurrent: (callback) ->
        response =
          temperature: googleCalendarTemp
        callback(response)

    Collector.prototype.googleCalendar = () ->
      fakeGoogleCalendar

    [fakeProxy, fakeRRD, fakeGoogleCalendar]

describe 'Collector', ->
  before ->
    this.clock = sinon.useFakeTimers()

  after ->
    this.clock.restore()

  describe 'collectData', ->
    it 'marks the hvac value as 1 if the heat is on', ->
      [fakeProxy, fakeRRD, fakeGoogleCalendar] = CollectorTestHelper.setupFakes()
      new Collector('filename')

      fakeProxy.stdout.emit('data', '60.0 62 heat-on')
      fakeRRD.update.args[0][1].should.eql(['60.0', '62', 1])

    it 'marks the hvac value as 1 if the ac is on', ->
      [fakeProxy, fakeRRD, fakeGoogleCalendar] = CollectorTestHelper.setupFakes()
      new Collector('filename')

      fakeProxy.stdout.emit('data', '60.0 62 ac-on')
      fakeRRD.update.args[0][1].should.eql(['60.0', '62', -1])

    it 'marks the hvac value as 0 if the hvac is off', ->
      [fakeProxy, fakeRRD, fakeGoogleCalendar] = CollectorTestHelper.setupFakes()
      new Collector('filename')

      fakeProxy.stdout.emit('data', '60.0 62 off')
      fakeRRD.update.args[0][1].should.eql(['60.0', '62', 0])

  describe 'google calendar updater', ->
    it 'checks for updates from google calendar and sends them to the hardware', ->
      [fakeProxy, fakeRRD, fakeGoogleCalendar] = CollectorTestHelper.setupFakes(72)
      collector = new Collector('filename')

      this.clock.tick(60000)
      fakeProxy.stdin.toString('utf8', 0, 2).should.eql("#{String.fromCharCode(72)}\n")
