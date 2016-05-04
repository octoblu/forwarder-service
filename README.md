#Forwarder Subscription Service

This micro-service registers forwarder devices and can setup device message subscriptions on
behalf of the device owner.

## What are Forwarders?
Forwarders are devices that receive messages intended for other devices and forward the messages received
somewhere else - like a datastore or another messaging platform. They allow you to spy on messages sent, received or broadcast to or from your devices to another endpoint.

## Forwarder Subscription API
All APIs should have the following fields in the header of the HTTP request
````
meshblu_auth_uuid
meshblu_auth_token
````
The UUID and Token should belong to the user or device that will have subscriptions created on their behalf
### Get Forwarder Types /types GET
Get the list of forwarder types.
Returns `200` with forwarder types
````json
[{
    "name": "Elastic Search",
    "forwarderTypeId": "meshblu-forwarder-elasticsearch",
    "enabled": false,
    "logoUrl": "https://s3-us-west-2.amazonaws.com/octoblu-icons/channel/.svg",
    "deviceType": "forwarder:elasticsearch",
    "description": "",
    "connector": "meshblu-forwarder-elasticsearch",
    "schemas": {
        "version": "2.0.0",
        "configure": {
            "type": "object",
            "properties": {
                "exampleOption": {
                    "title": "example",
                    "type": "string",
                    "required": true
                }
            }
        }
    }
}]
````
### Get all forwarders /forwarders GET
Returns the list of forwarders that the
### Get Forwarder by UUID /forwarders/:UUID
### Get Forwarder Subscriptions /forwarders/:uuid/subscriptions
### Create Forwarder /forwarders POST
#### **Input**:
**__forwarderTypeId__** : The Id of the type of forwarder you want to create
**__configuration__** : The configuration options forwarder device to be created
````json
{
  "forwarderTypeId": "splunk-event-collector",
  "configuration": {
    "name": "My new forwarder",
    "username":"",
    "password": ""
  }
}
````
**Returns**
`200` if forwarderId maps to a valid forwarderType and the config object can be validated against the
forwarders configure schema

`400` if the forwarderId and config are invalid or missing

### Add Forwarder Subscription /forwarders/:uuid/subscriptions PUT
Will create a message subscriptions where the forwarder with the given uuid will
subscribe to messages of a given devices. If the message subscription already exists
the subscription will not be created.



### Remove Forwarder subscriptions /forwarders/:UUID/subscriptions DELETE

Register a new forwarder with the forwarder options in the body of the request
Input:
_forwarderOptions_ - The forwarder specific device options that need to be set upon registration of the forwarder.
 e.g
````json
 {
  "forwarderOptions": {
  "type": "forwarder:mongo",

  "host": "https://computes.io",
  "databaseName": "IoTDB",
  "user": "myuser",
  "password": ""
 }
}
````
Responses:
201 Forwarder successfully created
````json
 {
    "uuid": "new-forwarder-uuid",
    "type": "forwarder:mongo",
    "host": "https://computes.io",
    "port": "12341",
    "databaseName": "IoTDB",
    "user": "myuser",
    "password": "",
    "forwarderSubsriptions":{}

  }

````

### Create forwarder message subscriptions for devices /forwarder/:forwarder_uuid/subscribe PUT
Input:
__devices__ - Arr
  - Device UUIDs
  - Forwarder UUID
  - Subscription Type
Remove Message subscriptions from devices
  - Device UUIDs
  - Forwarder UUID
  - Subscription type (Broadcast | Send | Receive)
Add Device Message Subscription (Device UUID, Forwarder UUID, Subscription Type (Broadcast | Send | Receive))
Remove Device message subscription
  - Device UUID
  - Forwarder UUID
