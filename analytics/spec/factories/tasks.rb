FactoryBot.define do
  factory :task do
    account
    public_id { SecureRandom.uuid }
    title { Faker::Lorem.sentence }
    description { Faker::Lorem.paragraph }
    status { "open" }
    fee_price { rand(10..20) }
    complete_price { rand(20..40) }
  end
end
