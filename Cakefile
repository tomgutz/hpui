#---Include required libraries---
fs = require 'fs-extra'
muffin = require 'muffin' # https://github.com/hornairs/muffin
Q = require 'q' # https://github.com/kriskowal/q
path = require 'path'
{spawn, exec} = require 'child_process'

dir = 'temp'
build = 'build'

#---Options---
option '-w', '--watch', 'continue to watch the files and rebuild them when they change'
option '-p', '--production', 'build for production (will optimize code)'
option '-s', '--server', 'start a local server'
# todo: hook up the the info var to -l compile option
#option '-l', '--log', 'echo compilation logs'

task 'build', 'Build all + package', (options) ->
	#invoke 'build.setup'
	invoke 'build.dir'
	invoke 'precompile.vendor'
	
task 'build.setup', 'Setup the env, clean up old builds', (options) ->
	fs.rmrfSync build, (err) ->
		console.log err if err?.errno isnt 34

task 'build.dir', 'Create empty directory structure', (options) ->
	muffin.run
		files: ['./app/asset/**/*.*', './vendor/scripts/**/*.coffee', './vendor/scripts/**/*.js', './app/**/*.coffee', './app/view/template/**/*.hbs']
		options: options
		map:
			# todo: need to optimize this more
			'./app/asset/(.*)': (matches) -> 
				mkdir_p path.dirname "./#{dir}/#{matches[1]}"
				mkdir_p path.dirname "./#{build}/#{matches[1]}"
			'./vendor/scripts/chaplin/*/(.+)?.coffee$': (matches) ->  
				mkdir_p path.dirname "./#{dir}/javascripts/#{matches[1]}"
				mkdir_p path.dirname "./#{build}/javascripts/#{matches[1]}"
			'./vendor/scripts/*/(.+)?.js$': (matches) -> 
				mkdir_p path.dirname "./#{dir}/javascripts/#{matches[1]}"
				mkdir_p path.dirname "./#{build}/javascripts/#{matches[1]}"
			'./app/*/(.+).coffee': (matches) -> 
				mkdir_p path.dirname "./#{dir}/javascripts/#{matches[1]}"
				mkdir_p path.dirname "./#{build}/javascripts/#{matches[1]}"
			'./app/*/(.+?).hbs': (matches) -> 
				mkdir_p path.dirname "./#{dir}/javascripts/#{matches[1]}"
				mkdir_p path.dirname "./#{build}/javascripts/#{matches[1]}"
		before: ->
			if not path.existsSync "./#{dir}"
				fs.mkdirSync "./#{dir}"
			if not path.existsSync "./#{build}"
				fs.mkdirSync "./#{build}"
			if not path.existsSync "./#{dir}/stylesheets/"
				fs.mkdirSync "./#{dir}/stylesheets/"
			if not path.existsSync "./#{build}/stylesheets/"
				fs.mkdirSync "./#{build}/stylesheets/"

task 'precompile.vendor', 'Build Chaplin + jQuery, + Backbone + Underscore, Stylus files', (options) ->
	muffin.run
		files: ['./vendor/scripts/**/*.coffee', './vendor/scripts/**/*.js', './vendor/styles/**/*.styl', './vendor/styles/**/*.*']
		options: options
		map:
			'./vendor/scripts/chaplin/*/(.+)?.coffee$': (matches) -> muffin.compileScript matches[0], "./#{dir}/javascripts/#{matches[1]}.js", options
			'./vendor/scripts/*/(.+)?.js$': (matches) -> muffin.copyFile matches[0], "./#{dir}/javascripts/#{matches[1]}.js", options
			# todo: optimize this later to make the style copy/compile in one line.
			'./vendor/styles/*/(.+?).styl$': (matches) -> compileStylus matches[0], "./#{dir}/stylesheets/", options
			'./vendor/styles/*/(.+)?.css$': (matches) -> muffin.copyFile matches[0], "./#{dir}/stylesheets/#{matches[1]}.css", options
		after: ->
			invoke 'precompile.coffee'

task 'precompile.coffee', 'Build CoffeeScript', (options) ->
	muffin.run
		files: './app/**/*.coffee'
		options: options
		map:
			'./app/*/(.+).coffee': (matches) -> muffin.compileScript matches[0], "./#{dir}/javascripts/#{matches[1]}.js", options
		after: ->
			invoke 'precompile.stylus'

task 'precompile.stylus', 'Build Stylus', (options) ->
	muffin.run
		files: './app/view/css/**/*.styl'
		options: options
		map:
			'./app/view/css/*/(.+?).styl': (matches) -> compileStylus matches[0], "./#{dir}/stylesheets/", options
		after: ->
			invoke 'precompile.hbs'
			
task 'precompile.hbs', 'Build Handlebars', (options) ->
	muffin.run
		files: './app/view/template/**/*.hbs'
		options: options
		map:
			'./app/*/(.+?).hbs': (matches) -> compileHandlebars matches[0], "./#{dir}/javascripts/#{matches[1]}.js", options
		after: ->
			invoke 'copy.lib'

task 'copy.lib', 'Copy require.js', (options) ->
	muffin.copyFile('./node_modules/requirejs/require.js', "./#{dir}/javascripts/common/require.js").then ->
		invoke 'copy.asset'

task 'copy.asset', 'Copy assets', (options) ->
	muffin.run
		files: './app/asset/**/*.*'
		options: options
		map:
			'./app/asset/(.*)': (matches) -> muffin.copyFile matches[0], "./#{dir}/#{matches[1]}", options
		after: ->
			if options.production
				console.log 'Optimizing for production build'
				invoke 'package.production'
			else
				invoke 'package.dev'
				invoke 'build.server'
				invoke 'server.start'

task 'package.production', 'Package using r.js', (options) ->
	console.log "Packaging for development"
	q = muffin.exec "./node_modules/requirejs/bin/r.js -o ./package.js"
	Q.when q[1], outputResult

task 'package.dev', 'Package for dev (simply copy over the files)', (options) ->
	muffin.run
		files: "./temp/**/*.*"
		options: {}
		map: # this has to map to @dir above
			"./temp/(.*)": (matches) -> muffin.copyFile matches[0], "./#{build}/#{matches[1]}", options

task 'build.server', 'Builds dev server', (options) ->
	muffin.run
		files: './server/coffee/**/*.coffee'
		options: options
		map:
			'./server/coffee/(.*)?.coffee$': (matches) -> muffin.compileScript matches[0], "./server/javascript/#{matches[1]}.js", options

task 'server.start', 'Start local dev server', (options) ->
	console.log 'Starting dev server'
	server = exec "node ./server/app.js"

# Stylus
# This function gets every file and its path and compiles it 
# http://learnboost.github.com/stylus/docs/executable.html
compileStylus = (source, target, options) ->
	console.log "Compiling Stylus files: #{source} -> #{target}"
	fs.mkdir target, 0o755, (err) ->
		if err?.errno isnt 47
			console.log err
			return
		q = muffin.exec "node ./node_modules/stylus/bin/stylus -o #{target} -u ./node_modules/nib/lib/nib #{source}"
		Q.when q[1], outputResult

# HandleBars
# https://github.com/wycats/handlebars.js/
# http://handlebarsjs.com/precompilation.html
compileHandlebars = (source, target, options) ->
	console.log "Compiling HBS template: /#{target}"

	fs.mkdir path.dirname(target), 0o755, (err) ->
		if err?.errno isnt 47
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


mkdir_p = (filePath, mode = 0o777) ->
  # the regex takes care of OS 
  parts = path.normalize(filePath).split(/[/|\\\\]/)
  # todo: this if part I have not tested quite well but it seems to 
  # solve some directory problem that I have not encountered
  if parts[0] == ''
    parts.shift()
    parts[0] = "/#{parts[0]}"
  if parts.length > 1
    parts.pop()
    mkdir_p parts.join("/"), mode

  if not path.existsSync(filePath)
    console.log "Create directory: #{filePath} "
    fs.mkdirSync filePath

  return true
