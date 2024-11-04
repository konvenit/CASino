require 'addressable/uri'
require 'rotp'

module CASino
  module ProcessorConcern
    module TwoFactorAuthenticators
      class ValidationResult < CASino::ValidationResult; end

      def validate_one_time_password(otp, authenticator, remember_me = false)
        if authenticator.nil? || authenticator.expired?
          ValidationResult.new 'INVALID_AUTHENTICATOR', 'Authenticator does not exist or expired', :warn
        else
          totp = ROTP::TOTP.new(authenticator.secret, interval: CASino.config.two_factor_authenticator[:lifetime])
          if totp.verify(otp)
            if [true, "true", "1", 1].any? { |i| remember_me == i }
              authenticator.update!(active: true, expiry: CASino.config.two_factor_authenticator[:remember_me_period].seconds.from_now)
            else
              authenticator.update!(active: true, expiry: Time.current)
            end
            ValidationResult.new
          else
            ValidationResult.new 'INVALID_OTP', 'One-time password not valid', :warn
          end
        end
      end
    end
  end
end
