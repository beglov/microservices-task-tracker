# Preview all emails at http://localhost:3000/rails/mailers/payment_transaction
class PaymentTransactionPreview < ActionMailer::Preview
  def daily_payout_email
    account = Account.new(email: "test@test.com")
    sum = 100_500
    PaymentTransactionMailer.daily_payout_email(account:, sum:)
  end
end
