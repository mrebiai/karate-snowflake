function fn() {
    const kafkaConfig = { "bootstrap.servers": "broker:29092" };
    const kafkaClient = karate.callSingle("classpath:kafka/topology.feature@createClient", kafkaConfig).result;
    return {
        "projectName": "meal_factory",
        "kafkaClient": kafkaClient
    }
}