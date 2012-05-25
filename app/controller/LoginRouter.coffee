Router = require './Router'
LoginView = require 'views/LoginView'


module.exports = class LoginRouter extends Router
	routes:
		'login': 'login'
	
	views:
		'login': new LoginView
	
	login: ->
		@show views.login
