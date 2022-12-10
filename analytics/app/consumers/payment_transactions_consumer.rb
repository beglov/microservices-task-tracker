class PaymentTransactionsConsumer < Racecar::Consumer
  subscribes_to "payment-transactions"

  def process(message)
    Rails.logger.debug "-" * 80
    Rails.logger.info { "Received message from topic: #{message.topic}" }
    Rails.logger.info { "Received message: #{message.value}" }
    Rails.logger.debug "-" * 80

    event = JSON.parse(message.value, symbolize_names: true)

    case event[:event_name]
    when "PaymentTransactionAdded"
      PaymentTransactionService::Add.new(event).call
    end
  end
end
