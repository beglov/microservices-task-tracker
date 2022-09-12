require "rails_helper"

RSpec.describe "Добавление новой задачи", type: :system do
  before do
    create_list(:account, 2, role: "worker")

    sign_in account
    visit root_path
    click_on "Новая задача"
  end

  context "Администратор" do
    let(:account) { create(:account, role: "admin") }

    it "добавляет новую задачу" do
      fill_in "Описание", with: "Полить цветы"

      click_on "Сохранить"

      expect(page).to have_content "Task was successfully created"
      expect(page).to have_content "Полить цветы"
    end

    it "получает сообщение об ошибке сохраняя не заполненную форму" do
      click_on "Сохранить"

      expect(page).to have_content "Description can't be blank"
    end
  end

  context "Менеджер" do
    let(:account) { create(:account, role: "manager") }

    it "добавляет новую задачу" do
      fill_in "Описание", with: "Полить цветы"

      click_on "Сохранить"

      expect(page).to have_content "Task was successfully created"
      expect(page).to have_content "Полить цветы"
    end

    it "получает сообщение об ошибке сохраняя не заполненную форму" do
      click_on "Сохранить"

      expect(page).to have_content "Description can't be blank"
    end
  end

  context "Рабочий" do
    let(:account) { create(:account, role: "worker") }

    it "добавляет новую задачу" do
      fill_in "Описание", with: "Полить цветы"

      click_on "Сохранить"

      expect(page).to have_content "Task was successfully created"
      expect(page).to have_content "Полить цветы"
    end

    it "получает сообщение об ошибке сохраняя не заполненную форму" do
      click_on "Сохранить"

      expect(page).to have_content "Description can't be blank"
    end
  end
end
