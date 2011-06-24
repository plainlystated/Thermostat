(function() {
  var Graph, root;
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };
  Graph = (function() {
    function Graph(slug, graphLabel) {
      this.slug = slug;
      this.graphLabel = graphLabel;
    }
    Graph.prototype.init = function() {
      this.loadJSON('day');
      $('#past-day').click(__bind(function() {
        return this.loadJSON('day');
      }, this));
      $('#past-week').click(__bind(function() {
        return this.loadJSON('week');
      }, this));
      return $('#past-month').click(__bind(function() {
        return this.loadJSON('month');
      }, this));
    };
    Graph.prototype.loadJSON = function(windowSize) {
      return $.getJSON(this.jsonPath(windowSize), __bind(function(lineData) {
        var line, lines;
        $('.spinner').fadeOut(200);
        console.log("loaded data from " + (this.jsonPath()));
        lines = (function() {
          var _i, _len, _results;
          _results = [];
          for (_i = 0, _len = lineData.length; _i < _len; _i++) {
            line = lineData[_i];
            console.log(line);
            _results.push({
              data: line.data,
              label: line.label
            });
          }
          return _results;
        })();
        return $.plot($('#holder'), lines, {
          xaxis: {
            mode: 'time'
          },
          legend: {
            position: 'sw'
          }
        });
      }, this));
    };
    Graph.prototype.jsonPath = function(path) {
      return "/" + this.slug + "/data/" + path;
    };
    return Graph;
  })();
  root = typeof exports != "undefined" && exports !== null ? exports : this;
  root.Graph = Graph;
}).call(this);
