module TaskService
  class Close
    include Dry::Monads[:result, :do]

    def initialize(event)
      @event = event
    end

    def call
      yield validate_event
      account = yield find_account
      task = yield find_task
      task = yield close_task(task)

      transaction = nil
      ActiveRecord::Base.transaction do
        transaction = yield create_payment_transaction(account, task)
        update_balance(account, transaction)
      end

      Success(transaction)
    end

    private

    def validate_event
      SchemaRegistry.validate_event(@event, "tasks.closed", version: 1)
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

    def close_task(task)
      if task.update(status: :close)
        Success(task)
      else
        Failure(task.errors)
      end
    end

    def create_payment_transaction(account, task)
      transaction = account.payment_transactions.new(transaction_param(task))

      if transaction.save
        Success(transaction)
      else
        Failure(transaction.errors)
      end
    end

    def update_balance(account, transaction)
      account.balance += transaction.credit
      account.save(validate: false)
    end

    def transaction_param(task)
      {
        task_id: task.id,
        description: "Начисление денег за выполненную задачу",
        credit: task.complete_price,
        debit: 0,
      }
    end
  end
end
