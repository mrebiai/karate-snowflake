FROM confluentinc/cp-kafka-connect:8.0.0

RUN echo "\nInstalling all required connectors...\n" && \
confluent-hub install --no-prompt confluentinc/kafka-connect-jdbc:10.8.4 && \
confluent-hub install --no-prompt snowflakeinc/snowflake-kafka-connector:3.3.0

# * https://medium.com/snowflake/streaming-data-from-snowflake-to-kafka-ed76ce0400c2