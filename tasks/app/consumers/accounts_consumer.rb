class AccountsConsumer < Racecar::Consumer
  subscribes_to "accounts-stream"
  subscribes_to "accounts"

  def process(message)
    puts '-' * 80
    Rails.logger.info { "Received message from topic: #{message.topic}" }
    Rails.logger.info { "Received message: #{message.value}" }
    puts '-' * 80

    event = JSON.parse(message.value, symbolize_names: true)

    case event[:event_name]
    when 'AccountCreated'
      Account.create!(
        public_id: event[:data][:public_id],
        role: event[:data][:role],
        email: event[:data][:email],
        full_name: event[:data][:full_name],
      )
    when 'AccountUpdated'
      account = Account.find_by!(public_id: event[:data][:public_id])
      account.update!(
        role: event[:data][:role],
        email: event[:data][:email],
        full_name: event[:data][:full_name],
      )
    when 'AccountDeleted'
      account = Account.find_by!(public_id: event[:data][:public_id])
      account.destroy
    when 'AccountRoleChanged'
      account = Account.find_by!(public_id: event[:data][:public_id])
      account.update!(
        role: event[:data][:role],
      )
    else
      # store events in DB
    end
  end
end
