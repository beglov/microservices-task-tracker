require 'rails_helper'

RSpec.describe "tasks/new", type: :view do
  before(:each) do
    assign(:task, Task.new(
      account: nil,
      public_id: "",
      description: "MyText",
      status: "MyString"
    ))
  end

  it "renders new task form" do
    render

    assert_select "form[action=?][method=?]", tasks_path, "post" do

      assert_select "input[name=?]", "task[account_id]"

      assert_select "input[name=?]", "task[public_id]"

      assert_select "textarea[name=?]", "task[description]"

      assert_select "input[name=?]", "task[status]"
    end
  end
end
