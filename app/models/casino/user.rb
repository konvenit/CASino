
class CASino::User < ActiveRecord::Base
  serialize :extra_attributes, Hash

  has_many :ticket_granting_tickets
  has_one  :two_factor_authenticator

  def cleanup_two_factor_authenticator
    two_factor_authenticator&.destroy
  end
end
