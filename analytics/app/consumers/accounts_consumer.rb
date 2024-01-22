class AccountsConsumer < ApplicationConsumer
  def consume
    messages.each do |message|
      Rails.logger.debug "-" * 80
      Rails.logger.info { "Received message from topic: #{message.topic}" }
      Rails.logger.info { "Received message: #{message.payload}" }
      Rails.logger.debug "-" * 80

      event = message.payload.deep_symbolize_keys

      case event[:event_name]
      when "AccountCreated"
        AccountService::Create.new(event).call
      when "AccountUpdated"
        AccountService::Update.new(event).call
      when "AccountDeleted"
        AccountService::Delete.new(event).call
      when "AccountRoleChanged"
        AccountService::ChangeRole.new(event).call
      else
        Rails.logger.info { "Unknown event: #{event[:event_name]}" }
      end
    end
  end
end
