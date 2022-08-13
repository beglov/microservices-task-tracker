FactoryBot.define do
  factory :task do
    account
    public_id { "" }
    description { "MyText" }
    status { "MyString" }
  end
end
