require "rails_helper"

RSpec.describe "Дашборд", type: :system do
  let(:most_expensive_task) { create(:task, title: "Самая дорогая задача") }

  before do
    account = create(:account)
    create(:payment_transaction, description: "Списание денег за назначенную задачу", debit: 15, credit: 0, account:, task: most_expensive_task)
    create(:payment_transaction, description: "Начисление денег за выполненную задачу", debit: 0, credit: 25, account:, task: most_expensive_task)
    create(:payment_transaction, description: "Списание денег за назначенную задачу", debit: 10, credit: 0)
    create(:payment_transaction, description: "Начисление денег за выполненную задачу", debit: 0, credit: 20)
    create(:payment_transaction, description: "Списание денег за назначенную задачу", debit: 11, credit: 0)
    create(:payment_transaction, description: "Списание денег за назначенную задачу", debit: 12, credit: 0)

    sign_in account
    visit root_path
  end

  context "Администратор" do
    let(:account) { create(:account, role: "admin") }

    it "просматривает дашборд" do
      expect(page).to have_content "Заработано за период: 3"
      expect(page).to have_content "Пользователей ушло в минус за период: 3"
      expect(page).to have_content "Самая дорогая задача за период: #{most_expensive_task.id} - #{most_expensive_task.title}"
    end
  end
end
