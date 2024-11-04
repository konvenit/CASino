class CASino::User < ActiveRecord::Base
  serialize :extra_attributes, type: Hash

  has_many :ticket_granting_tickets
  has_one  :two_factor_authenticator

  def cleanup_expired_two_factor_authenticator
    return unless two_factor_authenticator&.expired?
    two_factor_authenticator&.destroy
    reload
  end
end
