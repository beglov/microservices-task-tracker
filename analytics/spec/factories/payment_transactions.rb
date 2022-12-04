FactoryBot.define do
  factory :payment_transaction do
    account
    task
    description { Faker::Lorem.sentence }
    credit { rand(20..40) }
    debit { rand(10..20) }
  end
end
