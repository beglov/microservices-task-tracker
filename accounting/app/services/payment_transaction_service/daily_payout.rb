module PaymentTransactionService
  class DailyPayout
    include Dry::Monads[:result, :do]

    def call
      Account.where(role: :worker).where("balance > 0").each do |account|
        ActiveRecord::Base.transaction do
          transaction = yield create_payment_transaction(account)
          update_balance(account, transaction)
        end
      end

      Success()
    end

    private

    def create_payment_transaction(account)
      transaction = account.payment_transactions.new(payment_transactions_param(account))

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

    def payment_transactions_param(account)
      {
        description: "Выплата",
        credit: 0,
        debit: account.balance,
      }
    end
  end
end
