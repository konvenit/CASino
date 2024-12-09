require 'rotp'

# The TwoFactorAuthenticatorRegistrator processor can be used as the first step to register a new two-factor authenticator.
# It will create a secret that will be used by TwoFactorAuthenticatorAcceptor to verify the generated otp
#
class CASino::TwoFactorAuthenticatorRegistratorProcessor < CASino::Processor
  include CASino::ProcessorConcern::TicketGrantingTickets

  def process(user)
    person = Person.find(user.extra_attributes[:person_id])
    if person.allow_2fa_auth?
      two_factor_authenticator = CASino::TwoFactorAuthenticator.create! user: user, secret: ROTP::Base32.random_base32, expiry_at: CASino::TwoFactorAuthenticator.lifetime.from_now
      @listener.two_factor_authenticator_registered(two_factor_authenticator)
    end
  end
end
