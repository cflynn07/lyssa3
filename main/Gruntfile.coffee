module.exports = (grunt) ->

  grunt.initConfig
    pkg: grunt.file.readJSON 'package.json'
    coffeelint:
      client:    [
        'app/client/**/*.coffee'
      ]
      server:    [
        'app/server/**/*.coffee'
      ]
      options:
        indentation:
          value: 2
          level: 'error'
        no_empty_param_list:
          level: 'error'
        no_implicit_braces:
          level: 'error'
        no_implicit_parens:
          level: 'error'
        max_line_length:
          level: 'ignore'

  grunt.loadNpmTasks 'grunt-coffeelint'

  grunt.registerTask 'default', ['coffeelint']

#  grunt.registerTask 'default', 'Log some stuff.', () ->
#    grunt.log.write('Logging some stuff...').ok()
