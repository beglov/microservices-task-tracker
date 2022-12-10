require "rails_helper"

RSpec.describe AuthService do
  subject(:service) { described_class.new(OmniAuth::AuthHash.new(params)) }

  let(:params) do
    {
      provider: "doorkeeper",
      uid: account.public_id,
      info: {
        email: account.email,
        full_name: account.full_name,
        active: "active",
        role: account.role,
        public_id: account.public_id,
      },
    }
  end

  context "when user role is admin" do
    context "when account already exists" do
      let!(:account) { create(:account, role: "admin") }

      it "response with success" do
        expect(service.call).to be_success
      end

      it "does not create new account" do
        expect { service.call }.not_to change(Account, :count)
      end

      it "returns found account" do
        expect(service.call.success).to eq account
      end
    end

    context "when account does not exist" do
      let(:account) { build(:account, role: "admin") }

      it "response with success" do
        expect(service.call).to be_success
      end

      it "creates new account" do
        expect { service.call }.to change(Account, :count).by(1)
      end

      it "creates new account with correct attributes", :aggregate_failures do
        created_account = service.call.success

        expect(created_account.public_id).to eq account.public_id
        expect(created_account.full_name).to eq account.full_name
        expect(created_account.email).to eq account.email
        expect(created_account.role).to eq account.role
      end

      it "returns new account" do
        expect(service.call.success).to be_a Account
      end
    end
  end

  context "when user role is worker" do
    context "when account already exists" do
      let!(:account) { create(:account, role: "worker") }

      it "response with failure" do
        expect(service.call).to be_failure
      end

      it "does not create new account" do
        expect { service.call }.not_to change(Account, :count)
      end

      it "returns error message" do
        expect(service.call.failure).to eq "Доступ разрешен только Администратору"
      end
    end

    context "when account does not exist" do
      let(:account) { build(:account, role: "worker") }

      it "response with failure" do
        expect(service.call).to be_failure
      end

      it "creates new account" do
        expect { service.call }.to change(Account, :count).by(1)
      end

      it "returns error message" do
        expect(service.call.failure).to eq "Доступ разрешен только Администратору"
      end
    end
  end

  context "when user role is manager" do
    context "when account already exists" do
      let!(:account) { create(:account, role: "manager") }

      it "response with failure" do
        expect(service.call).to be_failure
      end

      it "does not create new account" do
        expect { service.call }.not_to change(Account, :count)
      end

      it "returns error message" do
        expect(service.call.failure).to eq "Доступ разрешен только Администратору"
      end
    end

    context "when account does not exist" do
      let(:account) { build(:account, role: "manager") }

      it "response with failure" do
        expect(service.call).to be_failure
      end

      it "creates new account" do
        expect { service.call }.to change(Account, :count).by(1)
      end

      it "returns error message" do
        expect(service.call.failure).to eq "Доступ разрешен только Администратору"
      end
    end
  end
end
