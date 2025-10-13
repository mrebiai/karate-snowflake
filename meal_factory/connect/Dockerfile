FROM confluentinc/cp-kafka-connect:8.0.0

RUN echo "\nInstalling all required connectors...\n" && \
confluent-hub install --no-prompt confluentinc/kafka-connect-jdbc:10.8.4 && \
confluent-hub install --no-prompt snowflakeinc/snowflake-kafka-connector:3.3.0
