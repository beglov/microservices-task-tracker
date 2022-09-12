FactoryBot.define do
  factory :task do
    account
    public_id { SecureRandom.uuid }
    description { Faker::Lorem.paragraph }
    status { "open" }
  end
end
