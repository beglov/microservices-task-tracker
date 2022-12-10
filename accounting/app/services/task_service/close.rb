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
        produce_event(transaction)
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

    def create_payment_transaction(_account, task)
      transaction = PaymentTransaction.new(payment_transaction_param(task))

      if transaction.save
        transaction.reload # выполняем пезагрузку что бы появились данные в поле public_id
        Success(transaction)
      else
        Failure(transaction.errors)
      end
    end

    def update_balance(account, transaction)
      account.balance += transaction.credit
      account.save(validate: false)
    end

    def payment_transaction_param(task)
      {
        account_id: task.account_id,
        task_id: task.id,
        description: "Начисление денег за выполненную задачу",
        credit: task.complete_price,
        debit: 0,
      }
    end

    def produce_event(transaction)
      event = payment_transaction_event(transaction)

      result = SchemaRegistry.validate_event(event, "payment_transactions.added", version: 1)
      raise "PaymentTransactionAdded event not valid: #{result.failure}" if result.failure?

      Producer.new.call(event, topic: "payment-transactions")
    end

    def payment_transaction_event(transaction)
      {
        event_id: SecureRandom.uuid,
        event_version: 1,
        event_time: Time.zone.now.to_s,
        producer: "accounting_service",
        event_name: "PaymentTransactionAdded",
        data: {
          public_id: transaction.public_id,
          account_public_id: transaction.account.public_id,
          task_public_id: transaction.task&.public_id,
          description: transaction.description,
          credit: transaction.credit,
          debit: transaction.debit,
        },
      }
    end
  end
end
