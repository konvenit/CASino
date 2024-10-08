require_relative 'listener'

class CASino::TwoFactorAuthenticatorOverviewListener < CASino::Listener
  def user_not_logged_in
    # nothing to do here
  end

  def two_factor_authenticator_found(two_factor_authenticator)
    assign(:two_factor_authenticator, two_factor_authenticator)
  end
end
