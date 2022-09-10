require 'rdkafka'

class Producer
  def initialize
    config = { 'bootstrap.servers' => ENV.fetch("KAFKA_BROKER") }

    @producer = Rdkafka::Config.new(config).producer
  end

  def call(event, topic:)
    @producer.produce(
      topic: topic,
      payload: event.to_json,
    )
  end
end
