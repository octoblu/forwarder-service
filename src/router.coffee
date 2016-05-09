ForwarderSubscriptionController = require './controllers/forwarder-subscription-controller'
forwarderTypes = require './forwarder-types/forwarder-types'

class Router
  constructor: ({@forwarderSubscriptionService}) ->
  route: (app) =>
    forwarderSubscriptionController = new ForwarderSubscriptionController {@forwarderSubscriptionService}

    app.post '/forwarders', forwarderSubscriptionController.createForwarder
    app.get '/forwarders', forwarderSubscriptionController.getForwarders
    app.delete '/forwarders/:uuid', forwarderSubscriptionController.deleteForwarder
    app.get '/forwarders/:uuid/subscriptions', forwarderSubscriptionController.getForwarderSubscriptions
    app.post '/forwarders/:uuid/subscriptions', forwarderSubscriptionController.addForwarderSubscription
    app.delete '/forwarders/:uuid/subscriptions', forwarderSubscriptionController.removeForwarderSubscriptions
    app.get '/types', (req, res) ->
      res.status(200).send(forwarderTypes)

module.exports = Router
