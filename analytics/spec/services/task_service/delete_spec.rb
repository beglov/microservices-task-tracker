require "rails_helper"

RSpec.describe TaskService::Delete do
  subject(:service) { described_class.new(event) }

  context "with valid event" do
    let(:event) do
      {
        event_id: "a6c4cac8-50ce-49e0-bddd-10c366e991e0",
        event_version: 1,
        event_time: "2022-10-17 08:45:25 UTC",
        producer: "tasks_service",
        event_name: "TaskDeleted",
        data: {
          public_id: "7a07d172-410f-47bb-8693-9d781d3f368f",
        },
      }
    end

    context "when task exists" do
      before { create(:task, public_id: "7a07d172-410f-47bb-8693-9d781d3f368f") }

      it "response with success" do
        expect(service.call).to be_success
      end

      it "deletes task" do
        expect { service.call }.to change(Task, :count).by(-1)
      end
    end

    context "when task does not exist" do
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
