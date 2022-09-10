require 'rails_helper'

RSpec.describe "Ассайн задач", type: :system do
  before do
    sign_in account
    visit root_path
  end

  context "Администратор" do
    let(:account) { create(:account, role: "admin") }

    it "ассайнит задачи" do
      click_on "Заассайнить задачи"

      expect(page).to have_content "Задачи успешно заасайнены"
    end
  end

  context "Менеджер" do
    let(:account) { create(:account, role: "manager") }

    it "ассайнит задачи" do
      click_on "Заассайнить задачи"

      expect(page).to have_content "Задачи успешно заасайнены"
    end
  end

  context "Рабочий" do
    let(:account) { create(:account, role: "worker") }

    it "не может ассайнить задачи" do
      expect(page).to_not have_button "Заассайнить задачи"
    end
  end
end
