function fn() {
    // kafka
    const kafkaConfig = { "bootstrap.servers": "broker:29092" };
    const kafkaClient = karate.callSingle("classpath:kafka/topology.feature@createClient", kafkaConfig).result;
    // rabbitmq
    const rabbitmqConfig = { host: "rabbitmq", port: 5672, virtualHost: "/", username: "guest", password: "guest", ssl: false };
    const rabbitmqClient = karate.callSingle("classpath:rabbitmq/topology.feature@createClient", rabbitmqConfig).result;    return {
        "projectName": "meal_factory",
        "kafkaClient": kafkaClient,
        "rabbitmqClient": rabbitmqClient
    }
}