class ForwarderSubscriptionController
  constructor: ({@forwarderSubscriptionService}) ->

  hello: (request, response) =>
    {hasError} = request.query
    @forwarderSubscriptionService.doHello {hasError}, (error) =>
      return response.status(error.code || 500).send(error: error.message) if error?
      response.sendStatus(200)

module.exports = ForwarderSubscriptionController
