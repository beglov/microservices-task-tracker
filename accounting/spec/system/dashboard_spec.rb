require "rails_helper"

RSpec.describe "Дашборд", type: :system do
  before do
    create(:payment_transaction, description: "Списание денег за назначенную задачу", debit: 10, credit: 0, account:)
    create(:payment_transaction, description: "Списание денег за назначенную задачу", debit: 15, credit: 0)
    create(:payment_transaction, description: "Начисление денег за выполненную задачу", debit: 0, credit: 20)

    sign_in account
    visit root_path
  end

  context "Администратор" do
    let(:account) { create(:account, role: "admin") }

    it "видит количество заработанных за сегодня денег и список транзакций" do
      expect(page).to have_content "Заработано за сегодня: 5"
      expect(page).to have_content "Транзакции проведенные #{Time.zone.now.strftime('%d.%m.%Y')}"
    end
  end

  context "Менеджер" do
    let(:account) { create(:account, role: "manager") }

    it "видит количество заработанных за сегодня денег и список транзакций" do
      expect(page).to have_content "Заработано за сегодня: 5"
      expect(page).to have_content "Транзакции проведенные #{Time.zone.now.strftime('%d.%m.%Y')}"
    end
  end

  context "Рабочий" do
    let(:account) { create(:account, role: "worker", balance: -30) }

    it "видит количество заработанных за сегодня денег и список транзакций" do
      expect(page).to have_content "Заработано за сегодня: -30"
      expect(page).to have_content "Транзакции проведенные #{Time.zone.now.strftime('%d.%m.%Y')}"
    end
  end
end
