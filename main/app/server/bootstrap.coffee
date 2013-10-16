crypto        = require 'crypto'
requirejs     = require 'requirejs'
async         = require 'async'
execSync      = require 'exec-sync'
fs            = require 'fs'


try
  output = execSync 'cd ~/code && pwd -P'
catch e
  console.log 'execSync error -- localhost?'
  #console.log e
  try
    output = execSync 'cd ~/ && pwd'
  catch e
    output = Date.now() + ''

GLOBAL.assetHash = crypto.createHash('md5').update(output).digest("hex")
console.log 'GLOBAL.assetHash'
console.log GLOBAL.assetHash

localPath = __dirname + '/../client/assets/' + GLOBAL.assetHash
if fs.existsSync(localPath + '.css') and fs.existsSync(localPath + '.js')
  require './server'
  return
  
else
  async.parallel [
    (cb) ->

      #OPTIMIZE CSS
      requirejs.optimize
        cssIn:        __dirname + '/../client/assets/client.css'
        out:          __dirname + '/../client/assets/' + GLOBAL.assetHash + '.css'
        optimizeCss: 'standard.keepLines' #standard
        preserveLicenseComments: false
        (buildResponse) ->
          cb()
            #console.log 'requirejs comp'
            #console.log buildResponse
        (err) ->
          cb()
            #console.log 'requirejs err'
            #console.log err
    (cb) ->

      config =
        baseUrl:                   __dirname + '/../client/'
        name:                     'vendor/require'
        include:                  './client'
        preserveLicenseComments:  false
        out:                      __dirname + '/../client/assets/' + GLOBAL.assetHash + '.js'
        paths:
          'angular':              'vendor/angular'
          'angular-ui':           'vendor/angular-ui'
          'angular-bootstrap':    'vendor/angular-bootstrap'
          'text':                 'vendor/text'
          'coffee-script':        'vendor/coffee-script'
          'cs':                   'vendor/cs'
          'hbs':                  'vendor/hbs'
          'Handlebars':           'vendor/Handlebars'
          'i18nprecompile':       'vendor/hbs/i18nprecompile'
          'json2':                'vendor/hbs/json2'
          'io':                   'vendor/socket.io'
          'underscore':           'vendor/underscore'
          'underscore_string':    'vendor/underscore.string'
          'backbone':             'vendor/backbone'
          'jquery':               'vendor/jquery'
          'jquery-ui':            'vendor/jquery-ui'
          'bootstrap':            'vendor/bootstrap'
          'gritter':              'vendor/jquery.gritter'


          'bootstrapFileUpload':      'vendor/bootstrap-fileupload'
          'jqueryFileUpload':         'vendor/file-upload/jquery.fileupload'
          'jqueryFileUploadFp':       'vendor/file-upload/jquery.fileupload-fp'
          'jqueryFileUploadUi':       'vendor/file-upload/jquery.fileupload-ui'
          'jqueryIframeTransport':    'vendor/file-upload/jquery.iframe-transport'
          'jquery.ui.widget':         'vendor/file-upload/jquery.ui.widget'


          'jqueryUniform':            'vendor/jquery.uniform'
          'jqueryBrowser':            'vendor/jquery.browser'
          'jqueryMaskedInput':        'vendor/jquery.maskedinput'
          'datatables':               'vendor/jquery-dataTables'
          'datatables_bootstrap':     'vendor/DT_bootstrap'
          'jqueryDateFormat':         'vendor/jquery-dateFormat'
          'bootstrap-tree':           'vendor/bootstrap-tree'
          'pubsub':                   'vendor/pubsub'
          'fullCalendar':             'vendor/fullcalendar'
          'bootstrap-toggle-buttons': 'vendor/bootstrap-toggle-buttons'
          'uuid':                     'vendor/uuid'
          'ejs':                      'vendor/ejs'
          'async':                    'vendor/async'
          'jqueryTouchPunch':         'vendor/jquery.touch.punch'
          'boostrapDateTimePicker':   'vendor/bootstrap-datetimepicker'
          'soundmanager2':            'vendor/soundmanager2'
          'slimscroll':               'vendor/jquery.slimscroll'
          'moment':                   'vendor/moment'
          'highcharts':               'vendor/highcharts'
          'spacetree':                'vendor/spacetree'
        uglify:
          no_mangle: true
        hbs:
          disableI18n: true
          helperDirectory: 'views/helpers/'
          templateExtension: 'html'
        shim:
          angular:
            deps: ['jquery-ui', 'jqueryUniform']
            exports: 'angular'
          'angular-ui':
            deps:    ['angular', 'jquery', 'jquery-ui', 'jqueryMaskedInput']
            exports: 'angular'
          'angular-bootstrap':
            deps:    ['angular', 'jquery', 'jquery-ui', 'bootstrap']
            exports: 'angular'
          underscore:
            exports: '_'
          io:
            exports: 'io'
          cs:
            deps:    ['coffee-script']
          jquery:
            exports: '$'
          'jquery-ui':
            deps:    ['jquery']
          jqueryBrowser:
            deps:    ['jquery']
          jqueryUniform:
            deps:    ['jqueryBrowser', 'jquery']
          bootstrap:
            deps:    ['jquery']
          datatables:
            deps:    ['jquery']
          'bootstrap-tree':
            deps:    ['jquery']
          fullCalendar:
            deps:    ['jquery']
          pubsub:
            exports: 'pubsub'
          'bootstrap-toggle-buttons':
            deps:     ['jquery', 'bootstrap']
          ejs:
            exports: 'EJS'
          uuid:
            exports: 'uuid'
          async:
            exports: 'async'
          underscore_string:
            deps:    ['underscore']
          jqueryMaskedInput:
            deps:    ['jquery', 'jqueryBrowser']
          jqueryTouchPunch:
            deps:    ['jquery']
          boostrapDateTimePicker:
            deps:    ['jquery', 'jquery-ui', 'bootstrap']
          gritter:
            deps:    ['jquery']
          highcharts:
            deps:    ['jquery']

          #File-upload assets
          jqueryFileUpload:
            deps:    ['jquery']
          jqueryFileUploadFp:
            deps:    ['jquery']
          jqueryFileUploadUi:
            deps:    ['jquery']
          jqueryIframeTransport:
            deps:    ['jquery']
          'jquery.ui.widget':
            deps:    ['jquery']
          tmplMin:
            deps:    ['jquery']
          soundmanager2:
            exports: 'soundManager'
          slimscroll:
            deps:    ['jquery']
          spacetree:
            exports: '$jit'

      requirejs.optimize config,
        (buildResponse) ->
          console.log 'buildResponse'
          console.log buildResponse
          cb()
        (err) ->
          console.log 'error'
          console.log err
          cb()

  ], (err, results) ->
    require './server'

