class Graph
  constructor: (@slug, @graphLabel) ->

  loadJSON: () ->
    $.getJSON(this.jsonPath(), (data) =>
      $('.spinner').fadeOut(200)
      console.log("loaded data from #{this.jsonPath()}")

      setTimeout () ->
        $.plot($('#holder'),
          [ { data: data, label: @graphLabel } ], {
            xaxis: { mode: 'time', ticks: [data[3][0], data[7][0], data[11][0], data[15][0]] },
            legend: { position: 'sw' }
          }
        )
      , 250

    )

  jsonPath: () ->
    "/#{@slug}/data/month"

root = exports ? this
root.Graph = Graph
