async  = require 'async'
config = require '../config/config'
csv    = require 'csv'
fs     = require 'fs'

module.exports = (app) ->

  app.post '/csv-upload', (req, res, next) ->
    outputArray = []

    file = req.files.files[0]

    try
      csv()
        .from.stream(fs.createReadStream(file.path))
        .to.path('/tmp/tmpcsv' + Date.now())
        .transform((row) ->
          return row
        ).on('record', (row, index) ->
          outputArray.push row
        ).on('end', (count) ->
          res.end JSON.stringify outputArray
        )
