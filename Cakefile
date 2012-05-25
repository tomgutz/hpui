#---Options---
option '-w', '--watch', 'continue to watch the files and rebuild them when they change'
option '-m', '--minify', 'minify client side scripts'
# todo: hook up the the info var to -l compile option
#option '-l', '--log', 'echo compilation logs'


#---Include required libraries---
muffin = require 'muffin' # https://github.com/hornairs/muffin
Q = require 'q' # https://github.com/kriskowal/q
fs = require 'fs' # http://nodejs.org/api/fs.html
path = require 'path'

dir = 'temp'
build = 'build'

task 'build', 'Build all', (options) ->
	invoke 'clean'
	invoke 'build.basic'
	muffin.run
		files: "./temp/**/*.*"
		options: options
		map: # this has to map to @dir above
			"./temp/(.*)": (matches) -> muffin.copyFile matches[0], "./#{build}/#{matches[1]}", options
	
task 'build.production', 'Build all + minimize all', (options) ->
	invoke 'clean'
	invoke 'build.basic'
	invoke 'package'

task 'build.basic', 'Build the libs, app, and copy assets', (options) ->	
	invoke 'precompile.all'
	invoke 'copy.asset'
	
task 'clean', 'Clean the build folder', (options) ->
	muffin.exec "rm -fr #{build}"

task 'copy.asset', 'Copy assets', (options) ->
	muffin.run
		files: './app/asset/**/*.*'
		options: options
		map:
			'./app/asset/(.*)': (matches) -> muffin.copyFile matches[0], "./#{dir}/#{matches[1]}", options

task 'precompile.all', 'Build CoffeeScript, Stylus, Handlebars', (options) ->
	invoke 'precompile.vendor'
	invoke 'precompile.coffee'
	invoke 'precompile.stylus'
	invoke 'precompile.hbs'

task 'precompile.vendor', 'Build Chaplin + jQuery, + Backbone + Underscore', (options) ->
	muffin.run
		files: ['./vendor/scripts/**/*.coffee', './vendor/scripts/**/*.js']
		options: options
		map:
			'./vendor/scripts/chaplin/*/(.+)?.coffee$': (matches) -> muffin.compileScript matches[0], "./#{dir}/javascripts/#{matches[1]}.js", options
			'./vendor/scripts/*/(.+)?.js$': (matches) -> muffin.copyFile matches[0], "./#{dir}/javascripts/#{matches[1]}.js", options

task 'precompile.coffee', 'Build CoffeeScript', (options) ->
	muffin.run
		files: './app/**/*.coffee'
		options: options
		map:
			'./app/*/(.+).coffee': (matches) -> muffin.compileScript matches[0], "./#{dir}/javascripts/#{matches[1]}.js", options

task 'precompile.stylus', 'Build Stylus', (options) ->
	muffin.run
		files: './app/view/css/**/*.styl'
		options: options
		map:
			'./app/view/css/*/(.+?).styl': (matches) -> compileStylus matches[0], "./#{dir}/stylesheets/", options
				
			
task 'precompile.hbs', 'Build Handlebars', (options) ->
	muffin.run
		files: './app/view/template/**/*.hbs'
		options: options
		map:
			'./app/*/(.+?).hbs': (matches) -> compileHandlebars matches[0], "./#{dir}/javascripts/#{matches[1]}.js", options

task 'package', 'Package using r.js', (options) ->
	console.log "Packaging for development"
	q = muffin.exec "./node_modules/requirejs/bin/r.js -o ./package.js"
	Q.when q[1], outputResult



# Stylus
# This function gets every file and its path and compiles it 
# http://learnboost.github.com/stylus/docs/executable.html
compileStylus = (source, target, options) ->
	console.log "Compiling Stylus files: #{source}"
	muffin.mkdir_p target, 0o755, (err) ->
		if err
			console.log err
			return
		q = muffin.exec "./node_modules/stylus/bin/stylus -o #{target} -u ./node_modules/nib/lib/nib #{source}"
		Q.when q[1], outputResult

# HandleBars
# https://github.com/wycats/handlebars.js/
# http://handlebarsjs.com/precompilation.html
compileHandlebars = (source, target, options) ->
	console.log "Compiling HBS template: /#{target}"

	muffin.mkdir_p path.dirname(target), 0x1ED, (err) ->
		if err
			console.log err
			return
		q = muffin.exec "handlebars #{source} -f #{target}"
		Q.when q[1], outputResult

outputResult = (result) ->
	out = result[0]
	err = result[1]
	if not err and out
		console.log out
	err
