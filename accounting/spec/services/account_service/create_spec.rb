require "rails_helper"

RSpec.describe AccountService::Create do
  subject(:service) { described_class.new(event) }

  context "with valid event" do
    let(:event) do
      {
        event_id: "4f54d56a-6a96-40c4-931d-9afa9503b7e2",
        event_version: 1,
        event_time: "2022-10-17 13:24:44 +0000",
        producer: "auth_service",
        event_name: "AccountCreated",
        data: {
          public_id: "dc8d21e5-3cda-4b52-a1b0-4832402b0e46",
          email: "worker3@test.com",
          full_name: nil,
          role: "worker",
        },
      }
    end

    it "response with success" do
      expect(service.call).to be_success
    end

    it "creates new account" do
      expect { service.call }.to change(Account, :count).by(1)
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
