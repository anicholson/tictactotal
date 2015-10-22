gulp = require 'gulp'
sass = require 'gulp-sass'
concat = require 'gulp-concat'
merge = require 'gulp-merge'
minifyCSS = require 'gulp-minify-css'
jade = require 'gulp-jade'
run = require 'gulp-run'

source_paths =
  sass: 'src/sass/app.scss'
  ruby: 'src/ruby/*.rb'
  jade: 'src/html/*.jade'


watch_paths =
  sass: 'src/sass/**/*.scss'
  ruby: 'src/ruby/*.rb'
  jade: 'src/html/*.jade'

gulp.task 'html', ->
  gulp.src(source_paths.jade)
  .pipe(jade())
  .pipe(gulp.dest('public/'))

gulp.task 'sass', ->
  gulp.src(source_paths.sass)
  .pipe(sass())
  .pipe(minifyCSS())
  .pipe(concat('app.min.css'))
  .pipe(gulp.dest('public/css/'))

gulp.task 'watch', ->
  gulp.watch watch_paths.sass, ['sass']
  gulp.watch watch_paths.ruby, ['ruby']
  gulp.watch watch_paths.jade, ['html']

gulp.task 'ruby', ->
  run('bundle install', cwd: "#{__dirname}/src/ruby").exec()
  run('bundle exec rake', cwd: "#{__dirname}/src/ruby").exec()


gulp.task 'scripts', ['ruby']

gulp.task 'default', ['watch', 'html', 'sass', 'scripts']
