module TaskService
  class Create
    include Dry::Monads[:result, :do]

    def initialize(event)
      @event = event
    end

    def call
      yield validate_event
      account = yield find_account
      task = yield find_or_create_task(account)

      Success(task)
    end

    private

    def validate_event
      SchemaRegistry.validate_event(@event, "tasks.created", version: 2)
    end

    def find_account
      account = Account.find_by(public_id: @event[:data][:account_public_id])

      if account
        Success(account)
      else
        Failure("Account not fount")
      end
    end

    def find_or_create_task(account)
      task = Task.find_by(public_id: @event[:data][:public_id])
      return Success(task) if task

      task = account.tasks.new(task_param)

      if task.save
        Success(task)
      else
        Failure(task.errors)
      end
    end

    def task_param
      {
        public_id: @event[:data][:public_id],
        title: @event[:data][:title],
        jira_id: @event[:data][:jira_id],
        description: @event[:data][:description],
        status: @event[:data][:status],
        fee_price: rand(10..20),
        complete_price: rand(20..40),
      }
    end
  end
end
