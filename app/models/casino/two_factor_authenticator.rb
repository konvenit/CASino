class CASino::TwoFactorAuthenticator < ActiveRecord::Base
  belongs_to :user

  def self.cleanup
    where('(created_at < ?)', self.lifetime.ago).delete_all
  end

  def self.lifetime
    CASino.config.two_factor_authenticator[:lifetime].seconds
  end

  def expired?
    (Time.now - (self.created_at || Time.now)) > self.class.lifetime
  end
end
