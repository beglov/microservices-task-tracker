class TasksConsumer < Racecar::Consumer
  subscribes_to "tasks-stream"
  subscribes_to "tasks"

  def process(message)
    Rails.logger.debug "-" * 80
    Rails.logger.info { "Received message from topic: #{message.topic}" }
    Rails.logger.info { "Received message: #{message.value}" }
    Rails.logger.debug "-" * 80

    event = JSON.parse(message.value, symbolize_names: true)

    case event[:event_name]
    when "TaskCreated"
      TaskService::Create.new(event).call
    when "TaskUpdated"
      TaskService::Update.new(event).call
    when "TaskDeleted"
      TaskService::Delete.new(event).call
    when "TaskAssigned"
      TaskService::Assign.new(event).call
    when "TaskClosed"
      TaskService::Close.new(event).call
    else
      Rails.logger.info { "Unknown event: #{event[:event_name]}" }
    end
  end
end
