require 'addressable/uri'

module CASino
  module ProcessorConcern
    module TicketGrantingTickets

      include CASino::ProcessorConcern::Browser

      def find_valid_ticket_granting_ticket(tgt, user_agent, ignore_two_factor = false)
        ticket_granting_ticket = CASino::TicketGrantingTicket.where(ticket: tgt).first
        if ticket_granting_ticket.present?
          if ticket_granting_ticket.expired?
            Rails.logger.info "Ticket-granting ticket expired (Created: #{ticket_granting_ticket.created_at})"
            ticket_granting_ticket.destroy
            nil
          elsif !ignore_two_factor && ticket_granting_ticket.awaiting_two_factor_authentication?
            Rails.logger.info 'Ticket-granting ticket is valid, but two-factor authentication is pending'
            nil
          elsif same_browser?(ticket_granting_ticket.user_agent, user_agent)
            ticket_granting_ticket.user_agent = user_agent
            ticket_granting_ticket.touch
            ticket_granting_ticket.save!
            ticket_granting_ticket
          else
            Rails.logger.info 'User-Agent changed: ticket-granting ticket not valid for this browser'
            nil
          end
        end
      end

      def acquire_ticket_granting_ticket(authentication_result:, user_agent: nil, long_term: nil, processor:)
        user_data = authentication_result[:user_data]
        user = load_or_initialize_user(authentication_result[:authenticator], user_data[:username], user_data[:extra_attributes])
        cleanup_expired_ticket_granting_tickets(user)

        user.cleanup_two_factor_authenticator
        generate_two_factor_authenticator(user, processor)

        user.ticket_granting_tickets.create!({
          ticket: random_ticket_string('TGC'),
          awaiting_two_factor_authentication: user.two_factor_authenticator.present?,
          user_agent: user_agent,
          long_term: !!long_term
        })
      end

      def load_or_initialize_user(authenticator, username, extra_attributes)
        user = CASino::User.where(
          authenticator: authenticator,
          username: username).first_or_initialize
        user.extra_attributes = extra_attributes
        user.save!
        return user
      end

      def remove_ticket_granting_ticket(ticket_granting_ticket, user_agent = nil)
        tgt = find_valid_ticket_granting_ticket(ticket_granting_ticket, user_agent)
        unless tgt.nil?
          tgt.destroy
        end
      end

      def cleanup_expired_ticket_granting_tickets(user)
        CASino::TicketGrantingTicket.cleanup(user)
      end

      def generate_two_factor_authenticator(user, processor)
        two_fa_listener  = CASino::TwoFactorAuthenticatorRegistratorListener.new(processor.listener.controller)
        two_fa_processor = CASino::TwoFactorAuthenticatorRegistratorProcessor.new(two_fa_listener)
        two_fa_processor.process(user)
      end

      def generate_otp(ticket_granting_ticket)
        authenticator = ticket_granting_ticket.user.two_factor_authenticator
        totp = ROTP::TOTP.new(authenticator.secret, interval: CASino.config.two_factor_authenticator[:lifetime])

        otp_value = totp.now
        login_otp_proxy = Proxies::LoginOTP.new(otp: otp_value, person_id: ticket_granting_ticket.user.extra_attributes[:person_id])
        Notifikator.generate :login_2fa_auth, login_otp: login_otp_proxy
      end
    end
  end
end
