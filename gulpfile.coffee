gulp = require 'gulp'
sass = require 'gulp-sass'
concat = require 'gulp-concat'
minifyCSS = require 'gulp-minify-css'

source_paths =
  sass: 'src/sass/app.scss'

watch_paths =
  sass: 'src/sass/**/*.scss'

gulp.task 'sass', ->
  gulp.src(source_paths.sass)
  .pipe(sass())
  .pipe(minifyCSS())
  .pipe(concat('app.min.css'))
  .pipe(gulp.dest('public/css/'))

gulp.task 'watch', ->
  gulp.watch watch_paths.sass, ['sass']

gulp.task 'default', ['watch', 'sass']
