module AccountService
  class Delete
    include Dry::Monads[:result, :do]

    def initialize(event)
      @event = event
    end

    def call
      yield validate_event
      account = yield find_account
      delete_account(account)

      Success()
    end

    private

    def validate_event
      SchemaRegistry.validate_event(@event, "accounts.deleted", version: 1)
    end

    def find_account
      account = Account.find_by(public_id: @event[:data][:public_id])

      if account
        Success(account)
      else
        Failure("Account not fount")
      end
    end

    def delete_account(account)
      account.destroy
    end
  end
end
