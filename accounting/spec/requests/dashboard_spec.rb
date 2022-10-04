require "rails_helper"

RSpec.describe "Dashboards", type: :request do
  before do
    account = create(:account, role: "worker")
    sign_in account
  end

  describe "GET /index" do
    it "returns http success" do
      get "/dashboard/index"
      expect(response).to have_http_status(:success)
    end
  end
end
