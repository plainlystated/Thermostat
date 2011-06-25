(function() {
  var Graph, root;
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };
  Graph = (function() {
    function Graph(slug, graphLabel) {
      this.slug = slug;
      this.graphLabel = graphLabel;
    }
    Graph.prototype.init = function() {
      this.show('day');
      $('#past-day').click(__bind(function() {
        return this.show('day');
      }, this));
      $('#past-week').click(__bind(function() {
        return this.show('week');
      }, this));
      return $('#past-month').click(__bind(function() {
        return this.show('month');
      }, this));
    };
    Graph.prototype.show = function(graphName) {
      this.loadJSON(graphName);
      this.showDetails(graphName);
      return false;
    };
    Graph.prototype.loadJSON = function(graphName) {
      return $.getJSON(this.jsonPath(graphName), __bind(function(lineData) {
        var line, lines;
        $('.spinner').fadeOut(200);
        lines = (function() {
          var _i, _len, _results;
          _results = [];
          for (_i = 0, _len = lineData.length; _i < _len; _i++) {
            line = lineData[_i];
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
    Graph.prototype.showDetails = function(name) {
      $('.arrows').remove();
      $('<span class="arrows">&#187;</span>').insertBefore($("#past-" + name + " > a"));
      $('.graph-details').each(function() {
        return $(this).hide();
      });
      $('#graph-details-' + name).show();
      return $('#current-graph-name').text("Past " + name);
    };
    Graph.prototype.jsonPath = function(path) {
      return "/" + this.slug + "/data/" + path;
    };
    return Graph;
  })();
  root = typeof exports != "undefined" && exports !== null ? exports : this;
  root.Graph = Graph;
}).call(this);
