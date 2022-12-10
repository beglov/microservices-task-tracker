module PaymentTransactionService
  class Add
    include Dry::Monads[:result, :do]

    def initialize(event)
      @event = event
    end

    def call
      yield validate_event
      account = yield find_account
      task = yield find_task
      payment_transaction = yield create_payment_transaction(account, task)

      Success(payment_transaction)
    end

    private

    def validate_event
      SchemaRegistry.validate_event(@event, "payment_transactions.added", version: 1)
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
      return Success(nil) if @event[:data][:task_public_id].blank?

      task = Task.find_by(public_id: @event[:data][:task_public_id])

      if task
        Success(task)
      else
        Failure("Task not fount")
      end
    end

    def create_payment_transaction(account, task)
      transaction = account.payment_transactions.new(payment_transaction_param(task))

      if transaction.save
        Success(transaction)
      else
        Failure(transaction.errors)
      end
    end

    def payment_transaction_param(task)
      {
        task_id: task&.id,
        public_id: @event[:data][:public_id],
        description: @event[:data][:description],
        credit: @event[:data][:credit],
        debit: @event[:data][:debit],
      }
    end
  end
end
