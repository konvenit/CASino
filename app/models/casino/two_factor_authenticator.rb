class CASino::TwoFactorAuthenticator < ActiveRecord::Base
  belongs_to :user

  def self.cleanup
    where('(expiry_at < ?)', Time.current).delete_all
  end

  def self.lifetime
    CASino.config.two_factor_authenticator[:lifetime].seconds
  end

  def expired?
    Time.current > self.expiry_at
  end
end
