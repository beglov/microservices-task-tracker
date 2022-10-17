require "rails_helper"

RSpec.describe TaskService::Update do
  subject(:service) { described_class.new(event) }

  context "with valid event" do
    let(:event) do
      {
        event_id: "d0f7133f-e317-4ec8-83a0-fbc844159ec1",
        event_version: 2,
        event_time: "2022-10-06 15:49:29 UTC",
        producer: "tasks_service",
        event_name: "TaskUpdated",
        data: {
          public_id: "1bc8eba5-7ef2-40a2-9193-2b0be4e8b6ed",
          title: "Фак",
          jira_id: "12345",
          description: "Полить цветы",
          status: "open",
          account_public_id: "66fe01aa-d2b0-4912-872d-8a4323522102",
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

      it "updates task", :aggregate_failures do
        task = service.call.success
        task.reload
        expect(task.title).to eq "Фак"
        expect(task.jira_id).to eq "12345"
        expect(task.description).to eq "Полить цветы"
        expect(task.status).to eq "open"
        expect(task.account.public_id).to eq "66fe01aa-d2b0-4912-872d-8a4323522102"
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
