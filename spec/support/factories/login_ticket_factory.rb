require 'factory_bot_rails'

FactoryBot.define do
  factory :login_ticket, class: CASino::LoginTicket do
    sequence :ticket do |n|
      "LT-ticket#{n}"
    end

    trait :consumed do
      consumed { true }
    end
    trait :expired do
      created_at { 601.seconds.ago }
    end
  end
end
