
class CASino::ProxyGrantingTicket < ActiveRecord::Base
  validates :ticket, uniqueness: { case_sensitive: true }
  validates :iou, uniqueness: { case_sensitive: true }
  belongs_to :granter, polymorphic: true
  has_many :proxy_tickets, dependent: :destroy
end
