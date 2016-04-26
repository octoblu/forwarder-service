gulp          = require 'gulp'
clean         = require 'gulp-clean'
gcson         = require 'gulp-cson'
jsonCombine     = require 'gulp-jsoncombine'

gulp.task 'clean', ->
  gulp.src('src/forwarder-types', read: false).pipe clean()

gulp.task 'build', ->
  gulp.src './forwarder-types/**/*.cson'
    .pipe gcson()
    .pipe jsonCombine('forwarder-types.json',  (data) -> new Buffer(JSON.stringify(data, null, 2)))
    .pipe gulp.dest './src/forwarder-types'

gulp.task 'watch', ->
  gulp.watch(['./forwarder-types/**/*.json'], ['build'])

gulp.task 'default', ['clean', 'build', 'watch']
