module TaskService
  class Assign
    include Dry::Monads[:result, :do]

    def initialize(event)
      @event = event
    end

    def call
      yield validate_event
      account = yield find_account
      task = yield find_or_create_task(account)

      ActiveRecord::Base.transaction do
        transaction = yield create_payment_transaction(account, task)
        update_balance(account, transaction)
        produce_event(transaction)
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

    def create_payment_transaction(account, task)
      transaction = account.payment_transactions.new(payment_transaction_param(task))

      if transaction.save
        transaction.reload # выполняем пезагрузку что бы появились данные в поле public_id
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

    def payment_transaction_param(task)
      {
        task_id: task.id,
        description: "Списание денег за назначенную задачу",
        credit: 0,
        debit: task.fee_price,
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
