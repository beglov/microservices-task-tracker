module AccountService
  class Update
    include Dry::Monads[:result, :do]

    def initialize(event)
      @event = event
    end

    def call
      yield validate_event
      account = yield find_account
      account = yield update_account(account)

      Success(account)
    end

    private

    def validate_event
      SchemaRegistry.validate_event(@event, "accounts.updated", version: 1)
    end

    def find_account
      account = Account.find_by(public_id: @event[:data][:public_id])

      if account
        Success(account)
      else
        Failure("Account not fount")
      end
    end

    def update_account(account)
      params = account_params

      if account.update(params)
        Success(account)
      else
        Failure(account.errors)
      end
    end

    def account_params
      {
        email: @event[:data][:email],
        full_name: @event[:data][:full_name],
        role: @event[:data][:role],
      }
    end
  end
end
