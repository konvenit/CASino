class CASino::TwoFactorAuthenticator < ActiveRecord::Base
  belongs_to :user

  def self.cleanup
    where('(expiry < ?)', Time.current).delete_all
  end

  def self.lifetime
    CASino.config.two_factor_authenticator[:lifetime].seconds
  end

  def expired?
    Time.current > self.expiry
  end
end
