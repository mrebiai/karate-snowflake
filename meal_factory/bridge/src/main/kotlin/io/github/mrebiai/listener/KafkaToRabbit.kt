package io.github.mrebiai.listener

import org.apache.kafka.clients.consumer.ConsumerRecord
import org.springframework.amqp.core.Message
import org.springframework.amqp.core.MessagePropertiesBuilder
import org.springframework.amqp.rabbit.core.RabbitTemplate
import org.springframework.kafka.annotation.KafkaListener
import org.springframework.stereotype.Component
import java.util.Date
import java.util.UUID

@Component
class KafkaToRabbit(
    private val rabbitTemplate: RabbitTemplate
) {

    @KafkaListener(topics = ["meal"], groupId = "bridge-group")
    fun listen(record: ConsumerRecord<String, String>) {
        rabbitTemplate.send("meal-exchange", "meal-rk.${record.key()}",
            Message(
                record.value().toByteArray(),
                MessagePropertiesBuilder.newInstance()
                .setHeader("clientId", record.key())
                .setAppId("bridge")
                .setMessageId(UUID.randomUUID().toString())
                .setCorrelationId(UUID.randomUUID().toString())
                .setTimestamp(Date())
                .setContentType("application/json")
                .build()
            )
        )
    }
}