class Account < ApplicationRecord
  has_many :tasks, dependent: :destroy
  has_many :payment_transactions, dependent: :destroy

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
