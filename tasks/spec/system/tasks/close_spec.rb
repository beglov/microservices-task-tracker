require 'rails_helper'

RSpec.describe "Закрытие задачи", type: :system do
  let!(:task) { create(:task) }

  before do
    sign_in account
    visit root_path
  end

  context "Рабочий" do
    let(:account) { create(:account, role: "worker") }

    it "закрывает задачу" do
      within "#task_#{task.id}" do
        expect(page).to have_content "open"
        click_on "Закрыть"
        expect(page).to have_content "close"
      end
    end
  end
end
