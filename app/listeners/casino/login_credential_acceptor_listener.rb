require_relative 'listener'

class CASino::LoginCredentialAcceptorListener < CASino::Listener
  attr_reader :controller

  def user_logged_in(url, ticket_granting_ticket, cookie_expiry_time = nil)
    tgt_cookie = { value: ticket_granting_ticket, expires: cookie_expiry_time, httponly: true }
    tgt_cookie[:secure] = true unless Rails.env.test?

    @controller.cookies[:tgt] = tgt_cookie
    ticket = CASino::TicketGrantingTicket.find_by_ticket(ticket_granting_ticket)
    person = Person.find(ticket.user.person_id)

    if !person.employee? && person.info_outdated?
      person.log_info_check
      @controller.redirect_to @controller.update_person_info_people_path(ref: redirect_url(url)), status: :see_other
    else
      @controller.redirect_to redirect_url(url), status: :see_other, allow_other_host: true
    end
  end

  def two_factor_authentication_pending(ticket_granting_ticket)
    assign(:ticket_granting_ticket, ticket_granting_ticket)
    @controller.render 'validate_otp'
  end

  def invalid_login_credentials(login_ticket)
    Rails.logger.error I18n.t('login_credential_acceptor.invalid_login_credentials')
    @controller.flash.now[:error] = I18n.t('login_credential_acceptor.invalid_login_credentials') if @controller.flash.blank?
    rerender_login_page(login_ticket)
  end

  def invalid_login_ticket(login_ticket)
    Rails.logger.error I18n.t('login_credential_acceptor.invalid_login_ticket')
    @controller.flash.now[:error] = I18n.t('login_credential_acceptor.invalid_login_ticket')
    rerender_login_page(login_ticket)
  end

  def service_not_allowed(service)
     Rails.logger.error  "service not allowed: #{service}"
    assign(:service, service)
    @controller.render 'service_not_allowed', status: 403
  end

  private
  def rerender_login_page(login_ticket)
    assign(:login_ticket, login_ticket)
    @controller.render 'new', status: 403
  end
end
