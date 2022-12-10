class AuthService
  include Dry::Monads[:result, :do]

  def initialize(params)
    @params = params
  end

  def call
    account = yield find_or_create_account

    Success(account)
  end

  private

  def find_or_create_account
    account = Account.find_by(public_id: @params.info.public_id)
    return Success(account) if account

    account = Account.new(account_params)

    if account.save
      Success(account)
    else
      Failure(account.errors)
    end
  end

  def account_params
    {
      public_id: @params.info.public_id,
      full_name: @params.info.full_name,
      email: @params.info.email,
      role: @params.info.role,
    }
  end
end
