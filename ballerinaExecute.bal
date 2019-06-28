import ballerina/io;import wso2/kafka;import ballerina/encoding;import ballerina/log;string[] SUBSCRIPTIONLIST = ["input"];string[] TRIGGERLIST = ["output"];string GROUPID = "abcd";string SERVERS = "localhost:9092";public function action(string message) returns string {
    io:println(message);
    return message;
}kafka:ConsumerConfig consumerConfig = {
    bootstrapServers: SERVERS,
    groupId: GROUPID,
    topics: SUBSCRIPTIONLIST,
    pollingInterval: 1
};
listener kafka:SimpleConsumer consumer = new(consumerConfig);
kafka:ProducerConfig producerConfig = {
    bootstrapServers: "localhost:9092",
    clientID: "basic-producer",
    acks: "all",
    noRetries: 3
};
kafka:SimpleProducer kafkaProducer = new(producerConfig);
service kafkaService on consumer {
    resource function onMessage(kafka:SimpleConsumer simpleConsumer, kafka:ConsumerRecord[] records) {
        foreach var entry in records {
            byte[] serializedMsg = entry.value;
            string msg = encoding:byteArrayToString(serializedMsg);
            foreach string triggerEvent in TRIGGERLIST {
                string message = action(msg);
                var sendResult = kafkaProducer -> send(message.toByteArray("UTF-8"), triggerEvent);
                if (sendResult is error) {
                    io:println("Failed to Send Data");
                }
            }
        }
    }
}
