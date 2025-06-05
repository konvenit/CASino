require 'factory_bot_rails'

FactoryBot.define do
  factory :user, class: CASino::User do
    authenticator { 'test' }
    sequence(:username) do |n|
      "test#{n}"
    end
    extra_attributes { { person_id: 1, fullname: "Test User", age: 15, roles: [:user] } }
  end
end
