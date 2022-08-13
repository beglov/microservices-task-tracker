require 'rails_helper'

RSpec.describe "tasks/edit", type: :view do
  before(:each) do
    @task = assign(:task, Task.create!(
      account: nil,
      public_id: "",
      description: "MyText",
      status: "MyString"
    ))
  end

  it "renders the edit task form" do
    render

    assert_select "form[action=?][method=?]", task_path(@task), "post" do

      assert_select "input[name=?]", "task[account_id]"

      assert_select "input[name=?]", "task[public_id]"

      assert_select "textarea[name=?]", "task[description]"

      assert_select "input[name=?]", "task[status]"
    end
  end
end
