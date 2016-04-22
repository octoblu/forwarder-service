ForwarderSubscriptionController = require './controllers/forwarder-subscription-controller'

class Router
  constructor: ({@forwarderSubscriptionService}) ->
  route: (app) =>
    forwarderSubscriptionController = new ForwarderSubscriptionController {@forwarderSubscriptionService}

    app.get '/hello', forwarderSubscriptionController.hello
    # e.g. app.put '/resource/:id', someController.update

module.exports = Router
