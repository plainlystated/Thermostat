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

    [fakeProxy, fakeRRD]

describe 'Collector', ->
  before ->
    this.clock = sinon.useFakeTimers()

  after ->
    this.clock.restore()

  describe 'collectData', ->
    it 'records the current temp', ->
      [fakeProxy, fakeRRD] = CollectorTestHelper.setupFakes()
      new Collector('filename')

      fakeProxy.stdout.emit('data', '60.0')
      fakeRRD.update.args[0][1].should.eql(['60.0'])
