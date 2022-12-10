require "rails_helper"

RSpec.describe "Вход в систему", type: :system do
  before { visit new_account_session_path }

  context "Пользователь зарегистрированный" do
    before do
      OmniAuth.config.mock_auth[:doorkeeper] = OmniAuth::AuthHash.new(
        provider: "doorkeeper",
        uid: account.public_id,
        info: {
          email: account.email,
          full_name: account.full_name,
          active: "active",
          role: account.role,
          public_id: account.public_id,
        },
      )
    end

    context "под ролью Администратор" do
      let(:account) { create(:account, role: "admin") }

      it "входит в систему" do
        expect(page).not_to have_button "Logout"
        click_on "Войти"
        expect(page).to have_button "Logout"
      end
    end

    context "под ролью Менеджер" do
      let(:account) { create(:account, role: "manager") }

      it "не может войти в систему" do
        expect(page).not_to have_button "Logout"
        click_on "Войти"
        expect(page).not_to have_button "Logout"
        expect(page).to have_content "Доступ разрешен только Администратору"
      end
    end

    context "под ролью Рабочий" do
      let(:account) { create(:account, role: "worker") }

      it "не может войти в систему" do
        expect(page).not_to have_button "Logout"
        click_on "Войти"
        expect(page).not_to have_button "Logout"
        expect(page).to have_content "Доступ разрешен только Администратору"
      end
    end
  end

  it "Пользователь видит сообщение об ошибке аутентификации" do
    OmniAuth.config.mock_auth[:doorkeeper] = :invalid_credentials
    click_on "Войти"
    expect(page).to have_content "Invalid credentials"
  end
end
