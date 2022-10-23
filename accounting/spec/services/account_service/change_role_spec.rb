require "rails_helper"

RSpec.describe AccountService::ChangeRole do
  subject(:service) { described_class.new(event) }

  context "with valid event" do
    let(:event) do
      {
        event_id: "3552ecc5-8419-4d46-8ae5-b0540c0fa1ea",
        event_version: 1,
        event_time: "2022-10-17 14:20:22 +0000",
        producer: "auth_service",
        event_name: "AccountRoleChanged",
        data: {
          public_id: "9bc5a0dd-d311-4d59-9885-9616724c5962",
          role: "manager",
        },
      }
    end

    context "when account found" do
      let!(:account) { create(:account, public_id: "9bc5a0dd-d311-4d59-9885-9616724c5962") }

      it "response with success" do
        expect(service.call).to be_success
      end

      it "changes account role" do
        expect {
          service.call
          account.reload
        }.to change(account, :role).to("manager")
      end
    end

    context "when account not found" do
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
