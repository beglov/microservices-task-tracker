require "rails_helper"

RSpec.describe "Вход в систему", type: :system do
  let(:account) { create(:account) }

  before { visit new_account_session_path }

  it "Зарегистрированный пользователь входит в систему" do
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

    expect(page).not_to have_button "Logout"
    click_on "Войти"
    expect(page).to have_button "Logout"
  end

  it "Пользователь видит сообщение об ошибке аутентификации" do
    OmniAuth.config.mock_auth[:doorkeeper] = :invalid_credentials
    click_on "Войти"
    expect(page).to have_content "Invalid credentials"
  end
end
