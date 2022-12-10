require "rails_helper"

RSpec.describe TaskService::Close do
  subject(:service) { described_class.new(event) }

  context "with valid event" do
    let(:event) do
      {
        event_id: "d0f7133f-e317-4ec8-83a0-fbc844159ec1",
        event_version: 1,
        event_time: "2022-10-06 15:49:29 UTC",
        producer: "tasks_service",
        event_name: "TaskClosed",
        data: {
          public_id: "1bc8eba5-7ef2-40a2-9193-2b0be4e8b6ed",
          account_public_id: "66fe01aa-d2b0-4912-872d-8a4323522102",
        },
      }
    end

    context "when account and task exists" do
      let!(:account) { create(:account, public_id: "66fe01aa-d2b0-4912-872d-8a4323522102", balance: 100) }
      let!(:task) { create(:task, public_id: "1bc8eba5-7ef2-40a2-9193-2b0be4e8b6ed", account:) }

      it "response with success" do
        expect(service.call).to be_success
      end

      it "close task" do
        expect {
          service.call
          task.reload
        }.to change(task, :status).from("open").to("close")
      end

      it "creates payment transaction" do
        expect { service.call }.to change(PaymentTransaction, :count).from(0).to(1)
      end

      it "creates payment transaction with correct attrs", :aggregate_failures do
        transaction = service.call.success

        expect(transaction.account_id).to eq account.id
        expect(transaction.task_id).to eq task.id
        expect(transaction.description).to eq "Начисление денег за выполненную задачу"
        expect(transaction.debit).to eq 0
        expect(transaction.credit).to eq task.complete_price
      end

      it "updates account balance" do
        transaction = service.call.success
        new_balance = account.balance + transaction.credit
        account.reload
        expect(account.balance).to eq new_balance
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

    context "when task does not exist" do
      before { create(:account, public_id: "66fe01aa-d2b0-4912-872d-8a4323522102", balance: 100) }

      it "response with failure" do
        expect(service.call).to be_failure
      end

      it "returns error message" do
        expect(service.call.failure).to eq "Task not fount"
      end
    end

    context "when account does not exist" do
      it "response with failure" do
        expect(service.call).to be_failure
      end

      it "returns error message" do
        expect(service.call.failure).to eq "Account not fount"
      end
    end
  end

  context "with invalid event" do
    let(:event) do
      {}
    end

    it "response with failure" do
      expect(service.call).to be_failure
    end
  end
end
