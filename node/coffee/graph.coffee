class Graph
  constructor: (@slug, @graphLabel) ->

  init: () ->
    this.loadJSON('day')
    $('#past-day').click () =>
      this.loadJSON('day')
    $('#past-week').click () =>
      this.loadJSON('week')
    $('#past-month').click () =>
      this.loadJSON('month')

  loadJSON: (windowSize) ->
    $.getJSON(this.jsonPath(windowSize), (lineData) =>
      $('.spinner').fadeOut(200)
      console.log("loaded data from #{this.jsonPath()}")

      lines = for line in lineData
        console.log line
        { data: line.data, label: line.label }

      $.plot($('#holder'),
        lines, {
          xaxis: { mode: 'time' },
          legend: { position: 'sw' }
        }
      )

    )

  jsonPath: (path) ->
    "/#{@slug}/data/#{path}"

root = exports ? this
root.Graph = Graph
