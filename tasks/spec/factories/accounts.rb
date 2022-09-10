FactoryBot.define do
  factory :account do
    public_id { SecureRandom.uuid }
    full_name { "MyString" }
    email { "MyString" }
    role { "admin" }
  end
end
