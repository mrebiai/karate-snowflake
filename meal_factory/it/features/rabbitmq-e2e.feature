#
Feature: rabbitmq-e2e

    Background:
        * string clientId = base.random.uuid()
        # queue for final assert
        * json queueConfig = ({ rabbitmqClient, name: clientId, type: "classic", durable: false, exclusive: false, autoDelete: true })
        * json result = rabbitmq.topology.queue(queueConfig)
        * match result.status == "OK"
        * json bindingConfig = ({ rabbitmqClient, exchangeName: "meal-exchange", queueName: queueConfig.name, routingKey: "meal-rk." + queueConfig.name })
        * json result = rabbitmq.topology.bind(bindingConfig)
        * match result.status == "OK"

    Scenario: From ingredients to meal - nominal case
        ### INGREDIENTS ###
        * json publishConfig = ({ rabbitmqClient, exchangeName: "ingredients-exchange", routingKey: "ingredients-rk" })
        * json headers = ({ clientId: clientId })
        * json properties = ({ headers, contentType: "application/json" })
        * json message = ({ body: '{"potato":"🥔","bread":"🍞","meat":"🥩","vegetable":"🥬"}', properties })
        * json result = rabbitmq.message.publish({...publishConfig, message})
        * match result.status == "OK"

        ### MEAL ###
        * json consumeConfig = ({ rabbitmqClient, queueName: queueConfig.name, timeoutSeconds: 60, minNbMessages: 1 })
        * json result = rabbitmq.message.consume(consumeConfig)
        * match result.status == "OK"
        * match result.data[0].properties.headers.clientId == clientId
        * match result.data[0].properties.contentType == "application/json"
        * json body = result.data[0].body
        * match body.clientId == clientId
        * match body.burger == "🍔"
        * match body.sideDishes == "🍟"

    Scenario: From ingredients to meal - error case
        ### INGREDIENTS ###
        * json publishConfig = ({ rabbitmqClient, exchangeName: "ingredients-exchange", routingKey: "ingredients-rk" })
        * json headers = ({ clientId: clientId })
        * json properties = ({ headers, contentType: "application/json" })
        * json message = ({ body: '{"potato":"🥔","bread":"🍞","meat":"🥕","vegetable":"🥬"}', properties })
        * json result = rabbitmq.message.publish({...publishConfig, message})
        * match result.status == "OK"

        ### MEAL ###
        * json consumeConfig = ({ rabbitmqClient, queueName: queueConfig.name, timeoutSeconds: 60, minNbMessages: 1 })
        * json result = rabbitmq.message.consume(consumeConfig)
        * match result.status == "OK"
        * match result.data[0].properties.headers.clientId == clientId
        * match result.data[0].properties.contentType == "application/json"
        * json body = result.data[0].body
        * match body.clientId == clientId
        * match body.burger == "🍞 + 🥕 + 🥬"
        * match body.sideDishes == "🍟"
    
    Scenario Outline: From ingredients to meal - example case (<potato> + <bread> + <meat> + <vegetable> = <burger> + <sideDishes>)
        ### INGREDIENTS ###
        * json publishConfig = ({ rabbitmqClient, exchangeName: "ingredients-exchange", routingKey: "ingredients-rk" })
        * json headers = ({ clientId: clientId })
        * json properties = ({ headers, contentType: "application/json" })
        * json message = ({ body: '{"potato":"<potato>","bread":"<bread>","meat":"<meat>","vegetable":"<vegetable>"}', properties })
        * json result = rabbitmq.message.publish({...publishConfig, message})
        * match result.status == "OK"

        ### MEAL ###
        * json consumeConfig = ({ rabbitmqClient, queueName: queueConfig.name, timeoutSeconds: 60, minNbMessages: 1 })
        * json result = rabbitmq.message.consume(consumeConfig)
        * match result.status == "OK"
        * match result.data[0].properties.headers.clientId == clientId
        * match result.data[0].properties.contentType == "application/json"
        * json body = result.data[0].body
        * match body.clientId == clientId
        * match body.burger == "<burger>"
        * match body.sideDishes == "<sideDishes>"
        
        Examples:
            | potato | bread | meat | vegetable | burger       | sideDishes |
            | 🥔     | 🍞    | 🥩   | 🥬        | 🍔           | 🍟         |
            | 🥔     | 🍞    | 🍗   | 🍅        | 🍔           | 🍟         |
            | 🥦     | 🍞    | 🐟   | 🥬        | 🍔           | 🥦         |
            | 🥔     | 🍞    | 🥕   | 🥬        | 🍞 + 🥕 + 🥬 | 🍟         |

