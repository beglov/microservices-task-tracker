class DashboardController < ApplicationController
  def index
    @payment_transactions = PaymentTransaction.where(created_at: Time.zone.now.all_day)
  end
end
