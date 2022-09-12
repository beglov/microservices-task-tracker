class AddOmniauthToAccounts < ActiveRecord::Migration[7.0]
  change_table :accounts, bulk: true do |t|
    t.string :provider
    t.string :uid
  end
end
