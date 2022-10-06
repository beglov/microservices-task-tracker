FactoryBot.define do
  factory :payment_transaction do
    account
    task
    description { "MyString" }
    credit { "9.99" }
    debit { "9.99" }
  end
end
