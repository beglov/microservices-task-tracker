module AccountService
  class ChangeRole
    include Dry::Monads[:result, :do]

    def initialize(event)
      @event = event
    end

    def call
      yield validate_event
      account = yield find_account
      account = yield change_role(account)

      Success(account)
    end

    private

    def validate_event
      SchemaRegistry.validate_event(@event, "accounts.role_changed", version: 1)
    end

    def find_account
      account = Account.find_by(public_id: @event[:data][:public_id])

      if account
        Success(account)
      else
        Failure("Account not fount")
      end
    end

    def change_role(account)
      if account.update(role: @event[:data][:role])
        Success(account)
      else
        Failure(account.errors)
      end
    end
  end
end
