require "rails_helper"

RSpec.describe PaymentTransactionService::DailyPayout do
  subject(:service) { described_class.new }

  let!(:account) { create(:account, role: :worker, balance: 10) }

  it "response with success" do
    expect(service.call).to be_success
  end

  it "creates payment transaction" do
    expect { service.call }.to change(PaymentTransaction, :count).by(1)
  end

  it "creates payment transaction with correct attrs", :aggregate_failures do
    service.call
    transaction = account.payment_transactions.last
    expect(transaction.task_id).to be_nil
    expect(transaction.description).to eq "Выплата"
    expect(transaction.debit).to eq 10
    expect(transaction.credit).to eq 0
  end

  it "updates account balance" do
    service.call
    account.reload
    expect(account.balance).to eq 0
  end

  it "enqueue daily payout email" do
    expect { service.call }.to have_enqueued_mail(PaymentTransactionMailer, :daily_payout_email)
  end

  it "produce PaymentTransactionAdded event" do
    producer = instance_double(Producer, call: nil)
    allow(Producer).to receive(:new).and_return(producer)
    expect(producer).to receive(:call).with(
      hash_including(
        producer: "accounting_service",
        event_name: "PaymentTransactionAdded",
      ),
      topic: "payment-transactions",
    )
    service.call
  end
end
