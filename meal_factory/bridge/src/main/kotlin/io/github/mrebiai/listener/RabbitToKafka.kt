package io.github.mrebiai.listener

import com.fasterxml.jackson.core.type.TypeReference
import com.fasterxml.jackson.databind.ObjectMapper
import org.springframework.amqp.core.Message
import org.springframework.amqp.rabbit.annotation.Exchange
import org.springframework.amqp.rabbit.annotation.Queue
import org.springframework.amqp.rabbit.annotation.QueueBinding
import org.springframework.amqp.rabbit.annotation.RabbitListener
import org.springframework.kafka.core.KafkaTemplate
import org.springframework.stereotype.Component
import java.util.UUID

@Component
class RabbitToKafka(
    private val kafkaTemplate: KafkaTemplate<String, String>
) {
    private val objectMapper = ObjectMapper()

    @RabbitListener(
        bindings = [
            QueueBinding(
                value = Queue(value = "ingredients-queue", durable = "true"),
                exchange = Exchange(value = "ingredients-exchange", type = "topic", durable = "true"),
                key = ["ingredients-rk"]
            )
        ]
    )
    fun listenIngredients(message: Message) {
        val map : Map<String, String> = objectMapper.readValue(String(message.body), object : TypeReference<Map<String, String>>() {})
        val clientId = message.messageProperties.headers["clientId"]?.toString() ?: UUID.randomUUID().toString()
        map.entries.forEach { entry ->
            kafkaTemplate.send( entry.key, clientId,"""{"value":"${entry.value}"}""")
        }
    }

    @RabbitListener(
        bindings = [
            QueueBinding(
                value = Queue(value = "meal-queue", durable = "true"),
                exchange = Exchange(value = "meal-exchange", type = "topic", durable = "true"),
                key = ["meal-rk.*"]
            )
        ]
    )
    fun listenMeal(recordValue: String) {
        println(recordValue)
    }
}
