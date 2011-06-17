(function() {
  var Graph, root;
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };
  Graph = (function() {
    function Graph(slug, graphLabel) {
      this.slug = slug;
      this.graphLabel = graphLabel;
    }
    Graph.prototype.loadJSON = function() {
      return $.getJSON(this.jsonPath(), __bind(function(data) {
        $('.spinner').fadeOut(200);
        console.log("loaded data from " + (this.jsonPath()));
        return setTimeout(function() {
          return $.plot($('#holder'), [
            {
              data: data,
              label: this.graphLabel
            }
          ], {
            xaxis: {
              mode: 'time',
              ticks: [data[3][0], data[7][0], data[11][0], data[15][0]]
            },
            legend: {
              position: 'sw'
            }
          });
        }, 250);
      }, this));
    };
    Graph.prototype.jsonPath = function() {
      return "/" + this.slug + "/data/month";
    };
    return Graph;
  })();
  root = typeof exports != "undefined" && exports !== null ? exports : this;
  root.Graph = Graph;
}).call(this);
