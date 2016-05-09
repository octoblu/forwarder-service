MeshbluHttp    = require 'meshblu-http'
forwarderTypes = require '../forwarder-types/forwarder-types'
_              = require 'lodash'

class ForwarderSubscriptionService
  constructor: (@meshbluOptions)->

  getForwarders:(meshbluAuth, callback) =>
    meshbluHttp = @_getMeshbluHttp meshbluAuth
    query =
      owner: meshbluAuth.uuid
      $exists:
        forwarder: true

    meshbluHttp.search query, {}, callback

  getForwarderSubscriptions:({meshbluAuth, forwarderUuid},  callback ) =>
    meshbluHttp = @_getMeshbluHttp meshbluAuth
    meshbluHttp.subscriptions forwarderUuid, callback

  addForwarderSubscription: ({meshbluAuth, forwarderUuid, emitterUuid, type},  callback ) =>    
    meshbluHttp = @_getMeshbluHttp meshbluAuth

    update =
      $addToSet:
        "meshblu.whitelists.#{type}": {uuid: forwarderUuid}

    meshbluHttp.updateDangerously emitterUuid, update, (error) =>
      return callback(@_createError 403, "Cannot modify #{emitterUuid}" ) if error?

      meshbluHttp.createSubscription {
        subscriberUuid: forwarderUuid
        emitterUuid: emitterUuid
        type: type
      }, callback

  removeForwarderSubscription: ({meshbluAuth, forwarderUuid, emitterUuid, type},  callback ) =>
    meshbluHttp = @_getMeshbluHttp meshbluAuth
    update =
      $pull:
        "meshblu.whitelists.#{type}": {uuid: forwarderUuid}

    meshbluHttp.updateDangerously emitterUuid, update, (error) =>
      return callback(@_createError 403, "Cannot modify #{emitterUuid}" ) if error?

      meshbluHttp.deleteSubscription {
        subscriberUuid: forwarderUuid
        emitterUuid: emitterUuid
        type: type
      }, callback

  _createError: (code, message) =>
    error = new Error message
    error.code = code if code?
    return error

  _getMeshbluHttp: (meshbluAuth) =>
    meshbluConfig = _.extend {}, @meshbluOptions, meshbluAuth
    new MeshbluHttp meshbluConfig

module.exports = ForwarderSubscriptionService
