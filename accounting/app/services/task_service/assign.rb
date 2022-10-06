module TaskService
  class Assign
    include Dry::Monads[:result, :do]

    def initialize(event)
      @event = event
    end

    def call
      yield validate_event
      account = yield find_account
      task = yield create_task(account)
      ActiveRecord::Base.transaction do
        transaction = yield create_payment_transaction(account, task)
        update_balance(account, transaction)
      end

      Success(task)
    end

    private

    def validate_event
      SchemaRegistry.validate_event(@event, "tasks.assigned", version: 1)
    end

    def find_account
      account = Account.find_by(public_id: @event[:data][:account_public_id])

      if account
        Success(account)
      else
        Failure("Account not fount")
      end
    end

    def create_task(account)
      task = account.tasks.new(task_param)

      if task.save
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
      account.balance -= transaction.debit
      account.save(validate: false)
    end

    def task_param
      {
        public_id: @event[:data][:public_id],
        fee_price: rand(10..20),
        complete_price: rand(20..40),
      }
    end

    def transaction_param(task)
      {
        task_id: task.id,
        description: "Списание денег за назначенную задачу",
        credit: 0,
        debit: task.fee_price,
      }
    end
  end
end
