require.config
	#baseUrl: '/js/',
	paths:
		jquery: 'common/jquery-1.7.2'
		underscore: 'common/underscore-1.3.3'
		backbone: 'common/backbone-0.9.2'
		handlebars: 'common/handlebars'
		foundation: 'common/foundation'
	waitSeconds: 1

require ['jquery', 'underscore', 'backbone', 'handlebars', 'application', 'foundation'],
	($, _, Backbone, Handlebars, app) ->
		console.log 'test'
