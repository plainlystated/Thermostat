class Graph
  constructor: (@slug, @graphLabel) ->

  init: () ->
    this.show('day')
    $('#past-day').click () =>
      this.show('day')
    $('#past-week').click () =>
      this.show('week')
    $('#past-month').click () =>
      this.show('month')

  show: (graphName) ->
    this.loadJSON(graphName)
    this.showDetails(graphName)
    false

  loadJSON: (graphName) ->
    $.getJSON(this.jsonPath(graphName), (lineData) =>
      $('.spinner').fadeOut(200)

      lines = for line in lineData
        { data: line.data, label: line.label, color: line.color }

      $.plot($('#holder'),
        lines, {
          xaxis: { mode: 'time' },
          legend: { position: 'sw' }
        }
      )
    )

  showDetails: (name) ->
    $('.arrows').remove()
    $('<span class="arrows">&#187;</span>').insertBefore($("#past-#{name} > a"))

    $('.graph-details').each () ->
      $(this).hide()

    $('#graph-details-' + name).show()
    $('#current-graph-name').text "Past #{name}"

  jsonPath: (path) ->
    "/#{@slug}/data/#{path}"

root = exports ? this
root.Graph = Graph
