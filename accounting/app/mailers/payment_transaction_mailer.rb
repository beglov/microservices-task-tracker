class PaymentTransactionMailer < ApplicationMailer
  def daily_payout_email(account:, sum:)
    @sum = sum
    mail(to: account.email, subject: "Месье, заберите ваши деньги")
  end
end
