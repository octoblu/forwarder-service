forwarderTypes = require '../forwarder-types/forwarder-types'
_              = require 'lodash'
class ForwarderSubscriptionController
  constructor: ({@forwarderSubscriptionService}) ->
  _findForwarderType: (forwarderTypeId) =>
    forwarderType = _.find forwarderTypes, (forwarderType) ->
        return forwarderType.forwarderId == forwarderId

  createForwarder: (request, response) =>

    {config, forwarderTypeId} = request.body
    forwarderType = @_findForwarderType(forwarderTypeId)

    return res.status(400).send(error: "Missing Forwarder Type Id") unless forwarderTypeId
    return res.status(400).send(error: "Missing forwarder config") unless forwarderConfig
    return res.status(400).send(error: "Invalid Forwarder Type") unless forwarderType

    {meshbluAuth} = request
    @forwarderSubscriptionService.createForwarder forwarderType, config, meshbluAuth, (error, createdForwarder) =>
      console.log "The return from the service is"

      return response.status(error.code || 500).send(error: error.message) if error?
      response.status(201).send(createdForwarder)

module.exports = ForwarderSubscriptionController
