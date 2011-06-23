http = require('http')
sax = require("sax")
DateFormatter = require('./dateFormatter').DateFormatter

class GoogleCalendar
  constructor: () ->
    @calendar = "/calendar/feeds/963shrhe9d8g3d5h7le9uu72l8%40group.calendar.google.com/public/basic?singleevents=true&orderby=starttime&start-max=#{startMax()}&start-min=#{startMin()}"
    @client = http.createClient(80, "www.google.com")
    # this.getDetailed()

  getDetailed: () =>
    xml = ""
    request = @client.request('GET', @calendar, {})
    request.end()
    request.on('response', (response) =>
      response.setEncoding('utf8')
      response.on('data', (chunk) ->
        xml += chunk
      )
      response.on('end', () =>
        parser = sax.parser(true)
        indent = 0
        parser.onopentag = (tag) =>
          indent = indent + 1
          console.log("#{indent} #{tag.name}")
        parser.onattribute = (attr) =>
          console.log("#{indent}  -#{attr.name}")
        parser.ontext = (text) =>
          console.log("#{indent}    #{text}")
        parser.onclosetag = () =>
          indent = indent - 1

        parser.write(xml).close()
      )
    )

  getCurrent: (cb) =>
    try
      xml = ""
      request = @client.request('GET', @calendar, {})
      request.end()
      request.on('response', (response) =>
        response.setEncoding('utf8')
        response.on('data', (chunk) ->
          xml += chunk
        )
        response.on('end', () =>
          this.currentSetting xml, (entry) =>
            cb(entry)
        )
      )
    catch err
      console.log("Error parsing calendar: #{err}")

  currentSetting: (xml, cb) =>
    parser = sax.parser(true)
    parser.onopentag = (tag) =>
      if tag.name == "entry"
        this.readEntry(parser, cb)

    try
      parser.write(xml).close()
    catch error
      console.log("error parsing xml: #{error}")

  readEntry: (parser, cb) =>
    entry = {}
    parser.onopentag = (tag) =>
      if tag.name == "title"
        this.readTitle(entry, parser, cb)
      else if tag.name == "content"
        this.readContent(entry, parser, cb)
    parser.onclosetag = (tag) =>
      if tag.name == "entry"
        this.readEntry(parser, cb)

  readTitle: (entry, parser, cb) =>
    parser.ontext = (text) =>
      entry.temperature = parseTitle(text)
      if entry.temperature != undefined && entry.range != undefined
        cb(entry)
      parser.ontext = (text) ->

  readContent: (entry, parser, cb) =>
    parser.ontext = (text) =>
      entry.range = parseContent(text)
      if entry.temperature != undefined && entry.range != undefined
        cb(entry)
      parser.ontext = (text) ->

  parseContent = (content) ->
    result = content.match("When: (.*) to (.*)")
    if result
      return {start: result[1], end: result[2]}
    else
      return undefined

  parseTitle = (title) ->
    result = title.match("^(\\d+)$")
    if result
      return result[1]
    else
      return undefined

  startMax = () ->
    oneMinuteFromNow = new Date((new Date).getTime() + 1000 * 60 )
    dateFormatter = new DateFormatter(oneMinuteFromNow)
    dateFormatter.rfc3339()

  startMin = () ->
    dateFormatter = new DateFormatter(new Date)
    dateFormatter.rfc3339()

exports.GoogleCalendar = GoogleCalendar
