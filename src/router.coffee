ForwarderSubscriptionController = require './controllers/forwarder-subscription-controller'

class Router
  constructor: ({@forwarderSubscriptionService}) ->
  route: (app) =>
    forwarderSubscriptionController = new ForwarderSubscriptionController {@forwarderSubscriptionService}
    app.get '/forwarders', forwarderSubscriptionController.getForwarders
    app.get '/forwarders/:forwarderUuid/subscriptions', forwarderSubscriptionController.getForwarderSubscriptions
    app.post '/forwarders/:forwarderUuid/subscriptions/:emitterUuid/:type', forwarderSubscriptionController.addForwarderSubscription
    app.delete '/forwarders/:forwarderUuid/subscriptions/:emitterUuid/:type', forwarderSubscriptionController.removeForwarderSubscription
    app.get '/types', forwarderSubscriptionController.getForwarderTypes

module.exports = Router
