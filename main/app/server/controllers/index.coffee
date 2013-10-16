###
  Serves up the HTML skeleton of our SPA
###

async          = require 'async'
html_minifier  = require 'html-minifier'
config         = require GLOBAL.appRoot + 'config/config'

module.exports = (app) ->

  app.get '/', (req, res, next) ->

    async.map ['header', 'body', 'footer']
    , (item, callback) ->

      res.render item,
        environment: config.env
        assetHash:   GLOBAL.assetHash,
        (err, html) ->
          callback err, html

    , (err, results) ->

      html = results[1] + results[2]
      html = html_minifier.minify html,
        collapseWhitespace: true
        removeComments:     true
      #preseve comments in header
      head = html_minifier.minify results[0],
        collapseWhitespace: true
      html = head + html
      res.end html

