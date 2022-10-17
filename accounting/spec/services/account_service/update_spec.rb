require "rails_helper"

RSpec.describe AccountService::Update do
  subject(:service) { described_class.new(event) }

  context "with valid event" do
    let(:event) do
      {
        event_id: "5424b302-3c5a-49ff-ae0f-10fbe52cd8c5",
        event_version: 1,
        event_time: "2022-10-17 13:44:19 +0000",
        producer: "auth_service",
        event_name: "AccountUpdated",
        data: {
          public_id: "dc8d21e5-3cda-4b52-a1b0-4832402b0e46",
          email: "worker3@test.com",
          full_name: "Работничек 3",
          role: "worker",
        },
      }
    end

    context "when account found" do
      let!(:account) { create(:account, public_id: "dc8d21e5-3cda-4b52-a1b0-4832402b0e46") }

      it "response with success" do
        expect(service.call).to be_success
      end

      it "updates account" do
        expect {
          service.call
          account.reload
        }.to change(account, :full_name).to("Работничек 3")
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
