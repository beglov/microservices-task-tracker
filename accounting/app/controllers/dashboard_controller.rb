class DashboardController < ApplicationController
  def index
    @payment_transactions = current_account.worker? ? current_account.payment_transactions : PaymentTransaction.all
    @payment_transactions = @payment_transactions.where(created_at: Time.zone.now.all_day)
  end
end
