module TaskService
  class Delete
    include Dry::Monads[:result, :do]

    def initialize(event)
      @event = event
    end

    def call
      yield validate_event
      task = yield find_task
      delete_task(task)

      Success(task)
    end

    private

    def validate_event
      SchemaRegistry.validate_event(@event, "tasks.deleted", version: 1)
    end

    def find_task
      task = Task.find_by(public_id: @event[:data][:public_id])

      if task
        Success(task)
      else
        Failure("Task not fount")
      end
    end

    def delete_task(task)
      task.destroy
    end
  end
end
