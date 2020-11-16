class CASino::TwoFactorAuthenticator < ActiveRecord::Base
  belongs_to :user

  def self.cleanup
    where('(created_at < ?) AND active = ?', self.lifetime.ago, false).delete_all
  end

  def self.lifetime
    CASino.config.two_factor_authenticator[:lifetime_inactive].seconds
  end

  def expired?
    !self.active? && (Time.now - (self.created_at || Time.now)) > self.class.lifetime
  end
end
