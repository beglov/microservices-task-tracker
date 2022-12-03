class Account < ApplicationRecord
  devise :database_authenticatable,
         :omniauthable, omniauth_providers: %i[doorkeeper]

  def worker?
    role == "worker"
  end
end
