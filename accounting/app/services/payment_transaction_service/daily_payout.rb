module PaymentTransactionService
  class DailyPayout
    include Dry::Monads[:result, :do]

    def call
      Account.where(role: :worker).where("balance > 0").each do |account|
        ActiveRecord::Base.transaction do
          transaction = yield create_payment_transaction(account)
          update_balance(account, transaction)
          produce_event(transaction)
          PaymentTransactionMailer.daily_payout_email(account:, sum: transaction.debit).deliver_later
        end
      end

      Success()
    end

    private

    def create_payment_transaction(account)
      transaction = account.payment_transactions.new(payment_transaction_param(account))

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

    def payment_transaction_param(account)
      {
        description: "Выплата",
        credit: 0,
        debit: account.balance,
      }
    end

    def produce_event(transaction)
      event = payment_transaction_event(transaction)

      result = SchemaRegistry.validate_event(event, "payment_transactions.added", version: 1)
      raise "PaymentTransactionAdded event not valid: #{result.failure}" if result.failure?

      Karafka.producer.produce_async(payload: event.to_json, topic: "payment-transactions")
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
