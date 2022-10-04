FactoryBot.define do
  factory :task do
    account
    public_id { SecureRandom.uuid }
    title { Faker::Lorem.sentence }
    description { Faker::Lorem.paragraph }
    status { "open" }
  end
end
