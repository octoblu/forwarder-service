MeshbluHttp = require 'meshblu-http'
forwarderTypes = require '../forwarder-types/forwarder-types'
_ = require 'lodash'

class ForwarderSubscriptionService
  createForwarder: ( forwarderId, config, meshbluAuth,  callback) =>
    forwarderType = _.find forwarderTypes, (forwarder) ->
        return forwarder.forwarderId == forwarderId
    return callback @_createError(400, "Missing Forwarder Id") unless forwarderId
    return callback @_createError(400, "Missing forwarder config") unless config
    return callback @_createError(400, "Invalid Forwarder Type") unless forwarderType


    # return callback @_createError(755, 'Not enough dancing!') if hasError?
    # callback()


  _createError: (code, message) =>
    error = new Error message
    error.code = code if code?
    return error

module.exports = ForwarderSubscriptionService
