ForwarderSubscriptionController = require './controllers/forwarder-subscription-controller'
forwarderTypes = require './forwarder-types/forwarder-types'

class Router
  constructor: ({@forwarderSubscriptionService}) ->
  route: (app) =>
    forwarderSubscriptionController = new ForwarderSubscriptionController {@forwarderSubscriptionService}

    app.get '/forwarders', forwarderSubscriptionController.getForwarders
    app.get '/forwarders/:uuid/subscriptions', forwarderSubscriptionController.getForwarderSubscriptions
    app.post '/forwarders/:uuid/subscriptions', forwarderSubscriptionController.addForwarderSubscription
    app.delete '/forwarders/:forwarderUuid/subscriptions/:emitterUuid/:type', forwarderSubscriptionController.removeForwarderSubscription
    app.get '/types', (req, res) ->
      res.status(200).send(forwarderTypes)

module.exports = Router
