import ballerina/io;
import wso2/kafka;
import ballerina/encoding;
import ballerina/log;

string[] SUBSCRIPTIONLIST = ["input"];
string[] TRIGGERLIST = ["output"];
string GROUPID = "a";
string SERVERS = "localhost:9092";

public function doSomeThing(string message) returns () {
    io:println("Function Called");
}

//boilerplate after this
kafka:ConsumerConfig consumerConfig = {
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
                var sendResult = kafkaProducer -> send(msg.toByteArray("UTF-8"), triggerEvent);
                var _temp = doSomeThing(msg);
                if (sendResult is error) {
                    io:println("Failed to Send Data");
                }
            }
        }
    }
}
