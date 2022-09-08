require 'rails_helper'

RSpec.describe "Tasks", type: :system do
  # before do
  #   driven_by(:rack_test)
  # end

  scenario "вводит верные данные" do
    visit root_path
    expect(page).to have_text "You need to sign in or sign up before continuing"
    click_on "Войти"
  end
end
