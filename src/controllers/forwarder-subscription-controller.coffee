forwarderTypes = require '../forwarder-types/forwarder-types'
_              = require 'lodash'
class ForwarderSubscriptionController
  constructor: ({@forwarderSubscriptionService}) ->
  _findForwarderType: (forwarderTypeId) =>
    forwarderType = _.find forwarderTypes, (forwarderType) ->
        return forwarderType.forwarderTypeId == forwarderTypeId

  createForwarder: (request, response) =>

    {configuration, forwarderTypeId} = request.body
    forwarderType = @_findForwarderType(forwarderTypeId)

    return response.status(400).send(error: "Missing Forwarder Type Id") unless forwarderTypeId
    return response.status(400).send(error: "Missing forwarder configuration") unless configuration
    return response.status(400).send(error: "Invalid Forwarder Type") unless forwarderType

    {meshbluAuth} = request
    @forwarderSubscriptionService.createForwarder forwarderType, configuration, meshbluAuth, (error, createdForwarder) =>
      console.log "The return from the service is"

      return response.status(error.code || 500).send(error: error.message) if error?
      response.status(201).send(createdForwarder)

module.exports = ForwarderSubscriptionController
