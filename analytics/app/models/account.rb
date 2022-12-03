class Account < ApplicationRecord
  devise :database_authenticatable,
         :omniauthable, omniauth_providers: %i[doorkeeper]

  def admin?
    role == "admin"
  end

  def worker?
    role == "worker"
  end

  def manager?
    role == "manager"
  end
end
