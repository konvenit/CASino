require 'addressable/uri'
require 'rotp'

module CASino
  module ProcessorConcern
    module TwoFactorAuthenticators
      CASino::ProcessorConcern::TwoFactorAuthenticators.send(:remove_const, :ValidationResult) if defined?(CASino::ProcessorConcern::TwoFactorAuthenticators::ValidationResult)

      class ValidationResult < CASino::ValidationResult; end

      def validate_one_time_password(otp, authenticator)
        if authenticator.nil? || authenticator.expired?
          ValidationResult.new 'INVALID_AUTHENTICATOR', 'Authenticator does not exist or expired', :warn
        else
          totp = ROTP::TOTP.new(authenticator.secret)
          if totp.verify_with_drift(otp, CASino.config.two_factor_authenticator[:drift])
            ValidationResult.new
          else
            ValidationResult.new 'INVALID_OTP', 'One-time password not valid', :warn
          end
        end
      end
    end
  end
end
