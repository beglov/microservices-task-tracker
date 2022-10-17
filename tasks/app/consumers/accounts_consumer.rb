class AccountsConsumer < Racecar::Consumer
  subscribes_to "accounts-stream"
  subscribes_to "accounts"

  def process(message)
    Rails.logger.debug "-" * 80
    Rails.logger.info { "Received message from topic: #{message.topic}" }
    Rails.logger.info { "Received message: #{message.value}" }
    Rails.logger.debug "-" * 80

    event = JSON.parse(message.value, symbolize_names: true)

    case event[:event_name]
    when "AccountCreated"
      AccountService::Create.new(event).call
    when "AccountUpdated"
      AccountService::Update.new(event).call
    when "AccountDeleted"
      AccountService::Delete.new(event).call
    when "AccountRoleChanged"
      AccountService::ChangeRole.new(event).call
    end
  end
end
