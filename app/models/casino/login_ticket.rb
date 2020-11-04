class CASino::LoginTicket < ActiveRecord::Base
  validates :ticket, uniqueness: true

  def self.cleanup
    where('created_at < ?', CASino.config.login_ticket[:lifetime].seconds.ago).delete_all
  end

  def to_s
    self.ticket
  end
end
