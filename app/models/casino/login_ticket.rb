class CASino::LoginTicket < ActiveRecord::Base
  validates :ticket, uniqueness: { case_sensitive: true }

  def self.cleanup
    self.delete_all(['created_at < ?', CASino.config.login_ticket[:lifetime].seconds.ago])
  end

  def to_s
    self.ticket
  end
end
