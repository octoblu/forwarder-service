MeshbluHttp    = require 'meshblu-http'
forwarderTypes = require '../forwarder-types/forwarder-types'
_              = require 'lodash'

class ForwarderSubscriptionService
  constructor: (@meshbluOptions)->
    @V1_PERMISSION_MAP =
      'broadcast.sent': 'receiveWhitelist'
      'broadcast.received': 'configureWhitelist'
      'message.sent': 'configureWhitelist'
      'message.received': 'configureWhitelist'

  getForwarders:(meshbluAuth, callback) =>
    meshbluHttp = @_getMeshbluHttp meshbluAuth
    query =
      type:
        $regex: "^forwarder"

    meshbluHttp.search query, {}, callback

  getForwarderSubscriptions:({meshbluAuth, forwarderUuid},  callback ) =>
    meshbluHttp = @_getMeshbluHttp meshbluAuth
    meshbluHttp.subscriptions forwarderUuid, callback

  addForwarderSubscription: ({meshbluAuth, forwarderUuid, emitterUuid, type},  callback ) =>
    meshbluHttp = @_getMeshbluHttp meshbluAuth
    meshbluHttp.device emitterUuid, (error, emitter) =>
      return callback error if error?
      update = @getV2PermissionsUpdate {type, forwarderUuid} if emitter.meshblu?.version == '2.0.0'
      update ?= @getV1PermissionsUpdate {type, forwarderUuid}

      meshbluHttp.updateDangerously emitterUuid, update, (error) =>
        return callback(@_createError 403, "Cannot modify #{emitterUuid}" ) if error?

        meshbluHttp.createSubscription {
          subscriberUuid: forwarderUuid
          emitterUuid: emitterUuid
          type: type
        }, callback

  getV2PermissionsUpdate: ({type, forwarderUuid}) =>
    update =
      $addToSet:
        "meshblu.whitelists.#{type}": {uuid: forwarderUuid}

  getV1PermissionsUpdate: ({type, forwarderUuid}) =>
    update =
      $addToSet:
        "#{@V1_PERMISSION_MAP[type]}": forwarderUuid

  removeForwarderSubscription: ({meshbluAuth, forwarderUuid, emitterUuid, type},  callback ) =>
    meshbluHttp = @_getMeshbluHttp meshbluAuth
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
