FactoryBot.define do
  factory :account do
    public_id { SecureRandom.uuid }
    full_name { Faker::Name.name }
    email { Faker::Internet.unique.email }
    role { %w[admin worker manager].sample }
  end
end
