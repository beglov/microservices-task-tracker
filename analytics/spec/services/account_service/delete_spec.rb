require "rails_helper"

RSpec.describe AccountService::Delete do
  subject(:service) { described_class.new(event) }

  context "with valid event" do
    let(:event) do
      {
        event_id: "bfbedb3f-6e5a-4955-815d-9c6c4c2c16c1",
        event_version: 1,
        event_time: "2022-10-17 14:05:15 +0000",
        producer: "auth_service",
        event_name: "AccountDeleted",
        data: {
          public_id: "dc8d21e5-3cda-4b52-a1b0-4832402b0e46",
        },
      }
    end

    context "when account found" do
      before { create(:account, public_id: "dc8d21e5-3cda-4b52-a1b0-4832402b0e46") }

      it "response with success" do
        expect(service.call).to be_success
      end

      it "deletes account" do
        expect { service.call }.to change(Account, :count).by(-1)
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
