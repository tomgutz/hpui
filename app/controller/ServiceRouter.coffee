Router = require './Router'
ServiceIndexView = require 'views/ServiceIndexView'


module.exports = class ServiceRouter extends Router
	routes:
		'': 'index'
	
	views:
		'index': new ServiceIndexView
	
	index: ->
		@show views.index