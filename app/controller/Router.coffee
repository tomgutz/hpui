
module.exports = class LoginRouter extends Backbone.Router
	currentView: null
	
	show: (view) ->
		@currentView?.remove()
		@currentView = view