require 'rails_helper'

RSpec.describe "tasks/index", type: :view do
  before(:each) do
    assign(:tasks, [
      Task.create!(
        account: nil,
        public_id: "",
        description: "MyText",
        status: "Status"
      ),
      Task.create!(
        account: nil,
        public_id: "",
        description: "MyText",
        status: "Status"
      )
    ])
  end

  it "renders a list of tasks" do
    render
    assert_select "tr>td", text: nil.to_s, count: 2
    assert_select "tr>td", text: "".to_s, count: 2
    assert_select "tr>td", text: "MyText".to_s, count: 2
    assert_select "tr>td", text: "Status".to_s, count: 2
  end
end
