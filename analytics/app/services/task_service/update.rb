module TaskService
  class Update
    include Dry::Monads[:result, :do]

    def initialize(event)
      @event = event
    end

    def call
      yield validate_event
      account = yield find_account
      task = yield find_task
      task = yield update_task(account:, task:)

      Success(task)
    end

    private

    def validate_event
      SchemaRegistry.validate_event(@event, "tasks.updated", version: 2)
    end

    def find_account
      account = Account.find_by(public_id: @event[:data][:account_public_id])

      if account
        Success(account)
      else
        Failure("Account not fount")
      end
    end

    def find_task
      task = Task.find_by(public_id: @event[:data][:public_id])

      if task
        Success(task)
      else
        Failure("Task not fount")
      end
    end

    def update_task(account:, task:)
      params = task_param(account)

      if task.update(params)
        Success(task)
      else
        Success(task.errors)
      end
    end

    def task_param(account)
      {
        title: @event[:data][:title],
        jira_id: @event[:data][:jira_id],
        description: @event[:data][:description],
        status: @event[:data][:status],
        account_id: account.id,
      }
    end
  end
end
