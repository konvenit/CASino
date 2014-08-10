class CASino::AuthTokenTicket < ActiveRecord::Base
  include CASino::ModelConcern::Ticket
  validates :ticket, uniqueness: true

  def self.cleanup
    self.delete_all(['created_at < ?', CASino.config.auth_token_ticket[:lifetime].seconds.ago])
  end

  def self.ticket_prefix
    'ATT'.freeze
  end

  def to_s
    self.ticket
  end
end
