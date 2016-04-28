ForwarderSubscriptionController = require './controllers/forwarder-subscription-controller'
forwarderTypes = require './forwarder-types/forwarder-types'

class Router
  constructor: ({@forwarderSubscriptionService}) ->
  route: (app) =>
    forwarderSubscriptionController = new ForwarderSubscriptionController {@forwarderSubscriptionService}

    app.post '/forwarders', forwarderSubscriptionController.createForwarder

    app.get '/types', (req, res) =>
      res.status(200).send(forwarderTypes)

module.exports = Router
