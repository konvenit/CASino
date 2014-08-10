class CASino::Api::AuthTokenTicketsController < CASino::ApplicationController
  include CASino::ProcessorConcern::Tickets

  respond_to :json

  # POST /api/auth_token_tickets
  def create
    @ticket = CASino::AuthTokenTicket.create ticket: random_ticket_string('ATT')
    Rails.logger.debug "Created auth token ticket '#{@ticket.ticket}'"
    render action: :show
  end
end
