gulp        = require 'gulp'
clean       = require 'gulp-clean'
gcson       = require 'gulp-cson'
jsonCombine = require 'gulp-jsoncombine'
_           = require 'lodash'

gulp.task 'clean', ->
  gulp.src('src/forwarder-types', read: false).pipe clean()

gulp.task 'build', ->
  gulp.src './forwarder-types/**/*.cson'
    .pipe gcson()
    .pipe jsonCombine('forwarder-types.json',  (data) -> new Buffer(JSON.stringify(_.values(data))))
    .pipe gulp.dest './src/forwarder-types'
    
gulp.task 'default', ['clean', 'build']
