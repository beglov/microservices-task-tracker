require "rails_helper"

RSpec.describe "Выход из системы", type: :system do
  let(:account) { create(:account) }

  before do
    sign_in account
    visit root_path
  end

  it "Аутентифицированный пользователь выходит из системы" do
    click_on "Logout"
    expect(page).to have_button "Войти"
  end
end
