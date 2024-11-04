require 'factory_bot_rails'
require 'rotp'

FactoryBot.define do
  factory :two_factor_authenticator, class: CASino::TwoFactorAuthenticator do
    user
    secret do
      ROTP::Base32.random_base32
    end
    expiry { CASino::TwoFactorAuthenticator.lifetime.from_now }
  end
end
