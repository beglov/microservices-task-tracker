require "rails_helper"

RSpec.describe PaymentTransactionService::Add do
  subject(:service) { described_class.new(event) }

  context "with valid event" do
    let(:event) do
      {
        event_id: "8e2680a6-3a7b-4601-a7c3-99185c786b14",
        event_version: 1,
        event_time: "2022-12-10 11:39:33 UTC",
        producer: "accounting_service",
        event_name: "PaymentTransactionAdded",
        data: {
          public_id: "76298ce0-121c-480f-b6d5-d9ce22fc3637",
          account_public_id: "66fe01aa-d2b0-4912-872d-8a4323522102",
          task_public_id: "1bc8eba5-7ef2-40a2-9193-2b0be4e8b6ed",
          description: "Списание денег за назначенную задачу",
          credit: "0",
          debit: "13",
        },
      }
    end

    context "when account and task exists" do
      before do
        create(:account, public_id: "66fe01aa-d2b0-4912-872d-8a4323522102")
        create(:task, public_id: "1bc8eba5-7ef2-40a2-9193-2b0be4e8b6ed")
      end

      it "response with success" do
        expect(service.call).to be_success
      end

      it "creates new payment transaction" do
        expect { service.call }.to change(PaymentTransaction, :count).by(1)
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

    context "when task does not exist" do
      before { create(:account, public_id: "66fe01aa-d2b0-4912-872d-8a4323522102") }

      it "response with failure" do
        expect(service.call).to be_failure
      end

      it "returns error message" do
        expect(service.call.failure).to eq "Task not fount"
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
