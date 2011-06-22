http = require('http')
sax = require("sax")

class GoogleCalendar
  constructor: () ->
    @calendar = '/calendar/feeds/963shrhe9d8g3d5h7le9uu72l8%40group.calendar.google.com/public/basic'
    @client = http.createClient(80, "www.google.com")
    this.getCurrent()


  getCurrent: () =>
    xml = ""
    request = @client.request('GET', @calendar, {})
    request.end()
    request.on('response', (response) =>
      response.setEncoding('utf8')
      response.on('data', (chunk) ->
        xml += chunk
      )
      response.on('end', () =>
        this.currentSetting xml, (temp) =>
          console.log "current setting: #{temp}"
      )
    )

  currentSetting: (xml, cb) =>
    parser = sax.parser(true)
    parser.onopentag = (tag) =>
      if tag.name == "entry"
        this.readEntry(parser, cb)

    parser.write(xml).close()

  readEntry: (parser, cb) =>
    parser.onopentag = (tag) =>
      if tag.name == "title"
        this.readTitle(parser, cb)

  readTitle: (parser, cb) =>
    parser.ontext = (text) =>
      cb(text)
      parser.ontext = (text) ->
      parser.onopentag = (tag) ->


exports.GoogleCalendar = GoogleCalendar
