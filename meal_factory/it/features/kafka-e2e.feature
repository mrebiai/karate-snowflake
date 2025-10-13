Feature: kafka-e2e

    Background:
        * string clientId = base.random.uuid()
        * json result = kafka.message.subscribe({ kafkaClient, topic: "meal" })
        * match result.status == "OK"
        * json consumer = result.consumer

    Scenario: From ingredients to meal - nominal case
        ### INGREDIENTS ###
        # potato
        Given json record = ({ key: clientId, value: '{"VALUE":"🥔"}' })
        When json result = kafka.message.produce({ kafkaClient, topic: "potato", record })
        Then match result.status == "OK"
        * karate.log(result.recordMetadata)
        # bread
        Given json record = ({ key: clientId, value: '{"VALUE":"🍞"}' })
        When json result = kafka.message.produce({ kafkaClient, topic: "bread", record })
        Then match result.status == "OK"
        * karate.log(result.recordMetadata)
        # meat
        Given json record = ({ key: clientId, value: '{"VALUE":"🥩"}' })
        When json result = kafka.message.produce({ kafkaClient, topic: "meat", record })
        Then match result.status == "OK"
        * karate.log(result.recordMetadata)
        # vegetable
        Given json record = ({ key: clientId, value: '{"VALUE":"🥬"}' })
        When json result = kafka.message.produce({ kafkaClient, topic: "vegetable", record })
        Then match result.status == "OK"
        * karate.log(result.recordMetadata)

        ### MEAL ###
        When json result = kafka.message.consumeByKey({ consumer, key: clientId, timeoutSeconds: 60, maxMessages: 1 })
        Then match result.status == "OK"
        And match (result.data.length) == 1
        And json meal = result.data[0].value
        And match meal.CLIENT_ID == clientId
        And match meal.BURGER == "🍔"
        And match meal.FRIES == "🍟"

    Scenario: From ingredients to meal - error case
        ### INGREDIENTS ###
        Given table ingredients
            | topic       | value |
            | "potato"    | "🥔"  |
            | "bread"     | "🍞"  |
            | "meat"      | "🥕"  |
            | "vegetable" | "🥬"  |
        And json responses = karate.map(ingredients, (row) => kafka.message.produce({ kafkaClient, topic: row.topic, record: ({ key: clientId, value: '{"VALUE":"' + row.value + '"}' })}).status)
        And match each responses == "OK"

        ### MEAL ###
        When json result = kafka.message.consumeByKey({ consumer, key: clientId, timeoutSeconds: 60, maxMessages: 1 })
        Then match result.status == "OK"
        And match (result.data.length) == 1
        And json meal = result.data[0].value
        And match meal.CLIENT_ID == clientId
        And match meal.BURGER == "🍞 + 🥕 + 🥬"
        And match meal.FRIES == "🍟"

    Scenario Outline: From ingredients to meal - example case (<potato> + <bread> + <meat> + <vegetable> = <burger> + <fries>)
        ### INGREDIENTS ###
        Given table ingredients
            | topic       | value         |
            | "potato"    | "<potato>"    |
            | "bread"     | "<bread>"     |
            | "meat"      | "<meat>"      |
            | "vegetable" | "<vegetable>" |
        And json responses = karate.map(ingredients, (row) => kafka.message.produce({ kafkaClient, topic: row.topic, record: ({ key: clientId, value: '{"VALUE":"' + row.value + '"}' })}).status)
        And match each responses == "OK"

        ### MEAL ###
        When json result = kafka.message.consumeByKey({ consumer, key: clientId, timeoutSeconds: 60, maxMessages: 1 })
        Then match result.status == "OK"
        And match (result.data.length) == 1
        And json meal = result.data[0].value
        And match meal.CLIENT_ID == clientId
        And match meal.BURGER == "<burger>"
        And match meal.FRIES == "<fries>"

        Examples:
            | potato | bread | meat | vegetable | burger       | fries |
            | 🥔     | 🍞    | 🥩   | 🥬        | 🍔           | 🍟    |
            | 🥔     | 🍞    | 🍗   | 🍅        | 🍔           | 🍟    |
            | 🥦     | 🍞    | 🐟   | 🥬        | 🍔           | 🥦    |
            | 🥔     | 🍞    | 🥕   | 🥬        | 🍞 + 🥕 + 🥬 | 🍟    |

