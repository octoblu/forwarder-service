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

    return response.status(422).send(error: "Missing Forwarder Type Id") unless forwarderTypeId
    return response.status(422).send(error: "Missing forwarder configuration") unless configuration
    return response.status(422).send(error: "Invalid Forwarder Type") unless forwarderType

    {meshbluAuth} = request
    @forwarderSubscriptionService.createForwarder forwarderType, configuration, meshbluAuth, (error, createdForwarder) ->
      return response.status(error.code || 500).send(error: error.message) if error?
      response.status(201).send(createdForwarder)

  deleteForwarder: (request,response) =>
    {uuid} = request.params
    {meshbluAuth} = request
    return response.status(422).send(error: "Missing Forwarder Uuid") if _.isEmpty(uuid)
    @forwarderSubscriptionService.deleteForwarder meshbluAuth, uuid, (error, deleteResult) =>
      return response.status(error.code || 500).send(error: error.message) if error?
      response.status(200).send(deleteResult)

  getForwarders: (request, response) =>
    {meshbluAuth} = request
    @forwarderSubscriptionService.getForwarders meshbluAuth, (error, forwarders) ->
      return response.status(error.code || 500).send(error: error.message) if error?
      response.status(200).send(forwarders)

  getForwarderSubscriptions: (request, response) =>
    {meshbluAuth} = request
    {forwarderUuid} = request.params
    @forwarderSubscriptionService.getForwarderSubscriptions {meshbluAuth, forwarderUuid}, (error, forwarders) ->
      return response.status(error.code || 500).send(error: error.message) if error?
      response.status(200).send(forwarders)

  addForwarderSubscription: (request, response) =>
    {meshbluAuth, params, body} = request
    {forwarderUuid, emitterUuid, type} = request.params

    @forwarderSubscriptionService.addForwarderSubscription {meshbluAuth, forwarderUuid, emitterUuid, type}, (error) =>
      return response.status(error.code || 500).send(error: error.message) if error?
      return response.sendStatus(201)

  removeForwarderSubscription: (request, response) =>
    {meshbluAuth} = request
    {forwarderUuid, emitterUuid, type} = request.params
    @forwarderSubscriptionService.removeForwarderSubscription {meshbluAuth, forwarderUuid, emitterUuid, type}, (error) =>
      return response.status(error.code || 500).send(error: error.message) if error?
      return response.sendStatus(204)



module.exports = ForwarderSubscriptionController
