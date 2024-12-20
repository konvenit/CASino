require 'addressable/uri'

class CASino::ProxyTicket < ActiveRecord::Base
  validates :ticket, uniqueness: { case_sensitive: true }
  belongs_to :proxy_granting_ticket
  has_many :proxy_granting_tickets, as: :granter, dependent: :destroy

  def self.cleanup_unconsumed
    where('created_at < ? AND consumed = ?', CASino.config.proxy_ticket[:lifetime_unconsumed].seconds.ago, false).destroy_all
  end

  def self.cleanup_consumed
    where('created_at < ? AND consumed = ?', CASino.config.proxy_ticket[:lifetime_consumed].seconds.ago, true).destroy_all
  end

  def expired?
    lifetime = if consumed?
      CASino.config.proxy_ticket[:lifetime_consumed]
    else
      CASino.config.proxy_ticket[:lifetime_unconsumed]
    end
    (Time.current - (self.created_at || Time.current)) > lifetime
  end
end
