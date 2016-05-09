forwarderTypes = require '../forwarder-types/forwarder-types'
_              = require 'lodash'

class ForwarderSubscriptionController
  constructor: ({@forwarderSubscriptionService}) ->

  getForwarders: (request, response) =>
    {meshbluAuth} = request
    @forwarderSubscriptionService.getForwarders meshbluAuth, (error, forwarders) ->
      return response.status(error.code || 500).send(error: error.message) if error?
      response.status(200).send(forwarders)

  getForwarderTypes: (request, response) =>
    response.status(200).send forwarderTypes

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
