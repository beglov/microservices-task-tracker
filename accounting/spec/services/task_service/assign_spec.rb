require "rails_helper"

RSpec.describe TaskService::Assign do
  subject(:service) { described_class.new(event) }

  context "with valid event" do
    let(:event) do
      {
        event_id: "d0f7133f-e317-4ec8-83a0-fbc844159ec1",
        event_version: 1,
        event_time: "2022-10-06 15:49:29 UTC",
        producer: "tasks_service",
        event_name: "TaskAssigned",
        data: {
          public_id: "1bc8eba5-7ef2-40a2-9193-2b0be4e8b6ed",
          account_public_id: "66fe01aa-d2b0-4912-872d-8a4323522102",
        },
      }
    end

    context "when account exists and task does not exist" do
      let!(:account) { create(:account, public_id: "66fe01aa-d2b0-4912-872d-8a4323522102", balance: 100) }

      it "response with success" do
        expect(service.call).to be_success
      end

      it "creates new task" do
        expect { service.call }.to change(Task, :count).from(0).to(1)
      end

      it "creates task with prices", :aggregate_failures do
        task = service.call.success

        expect(task.fee_price).to be_between(10, 20).inclusive
        expect(task.complete_price).to be_between(20, 40).inclusive
      end

      it "creates payment transaction" do
        expect { service.call }.to change(PaymentTransaction, :count).from(0).to(1)
      end

      it "creates payment transaction with correct attrs", :aggregate_failures do
        task = service.call.success
        transaction = PaymentTransaction.last

        expect(transaction.account_id).to eq account.id
        expect(transaction.task_id).to eq task.id
        expect(transaction.description).to eq "Списание денег за назначенную задачу"
        expect(transaction.debit).to eq task.fee_price
        expect(transaction.credit).to eq 0
      end

      it "updates account balance" do
        task = service.call.success
        new_balance = account.balance - task.fee_price
        account.reload
        expect(account.balance).to eq new_balance
      end

      it "produce payment transaction create event"
    end

    context "when account and task exists" do
      before do
        create(:account, public_id: "66fe01aa-d2b0-4912-872d-8a4323522102", balance: 100)
        create(:task, public_id: "1bc8eba5-7ef2-40a2-9193-2b0be4e8b6ed")
      end

      it "response with success" do
        expect(service.call).to be_success
      end

      it "does not creates new task" do
        expect { service.call }.not_to change(Task, :count)
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
