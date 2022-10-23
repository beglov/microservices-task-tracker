module AccountService
  class Create
    include Dry::Monads[:result, :do]

    def initialize(event)
      @event = event
    end

    def call
      yield validate_event
      account = yield create_account

      Success(account)
    end

    private

    def validate_event
      SchemaRegistry.validate_event(@event, "accounts.created", version: 1)
    end

    def create_account
      account = Account.new(account_param)

      if account.save
        Success(account)
      else
        Failure(account.errors)
      end
    end

    def account_param
      {
        public_id: @event[:data][:public_id],
        email: @event[:data][:email],
        role: @event[:data][:role],
        full_name: @event[:data][:full_name],
      }
    end
  end
end
