FactoryBot.define do
  factory :task do
    account
    public_id { SecureRandom.uuid }
    description { "MyText" }
    status { "MyString" }
  end
end
