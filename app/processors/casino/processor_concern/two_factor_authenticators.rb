require 'addressable/uri'
require 'rotp'

module CASino
  module ProcessorConcern
    module TwoFactorAuthenticators
      class ValidationResult < CASino::ValidationResult; end

      def validate_one_time_password(otp, authenticator)
        if authenticator.nil? || authenticator.expired?
          ValidationResult.new 'INVALID_AUTHENTICATOR', 'Authenticator does not exist or expired', :warn
        else
          totp = ROTP::TOTP.new(authenticator.secret, interval: CASino.config.two_factor_authenticator[:lifetime])
          if totp.verify(otp)
            ValidationResult.new
          else
            ValidationResult.new 'INVALID_OTP', 'One-time password not valid', :warn
          end
        end
      end
    end
  end
end
