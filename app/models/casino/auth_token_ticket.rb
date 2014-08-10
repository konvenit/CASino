class CASino::AuthTokenTicket < ActiveRecord::Base
  include CASino::ModelConcern::Ticket
  include CASino::ModelConcern::ConsumableTicket

  self.ticket_prefix = 'ATT'.freeze
  self.ticket_lifetime = CASino.config.auth_token_ticket[:lifetime].seconds

end
