
class ForwarderSubscriptionController
  constructor: ({@forwarderSubscriptionService}) ->

  createForwarder: (request, response) =>

    {config, forwarderId} = request.body
    {meshbluAuth} = request
    @forwarderSubscriptionService.createForwarder forwarderId, config, meshbluAuth, (error, createdForwarder) =>
      console.log "The return from the service is"
      return response.status(error.code || 500).send(error: error.message) if error?
      response.status(201).send(createdForwarder)

module.exports = ForwarderSubscriptionController
