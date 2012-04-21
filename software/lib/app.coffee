App = {
  Collector: require('./collector').Collector
  rrdFilepath: "db/hot-or-not.rrd"
  viewData: {
    title: "Hot Or Not",
    tagLine: "Keeping you cool since 2011",
    slug: "hot-or-not"
  }
}

exports.App = App
