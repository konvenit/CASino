require_relative 'listener'

class CASino::TwoFactorAuthenticationAcceptorListener < CASino::Listener

  def user_not_logged_in
    @controller.redirect_to login_path
  end

  def user_logged_in(url, ticket_granting_ticket, cookie_expiry_time = nil)
    tgt_cookie = { value: ticket_granting_ticket, expires: cookie_expiry_time, httponly: true }
    tgt_cookie[:secure] = true unless Rails.env.test?

    @controller.cookies[:tgt] = tgt_cookie
    ticket = CASino::TicketGrantingTicket.find_by_ticket(ticket_granting_ticket)
    person = Person.find(ticket.user.person_id)

    if person.employee? || person.phone_extension.present?
      @controller.redirect_to redirect_url(url), status: :see_other, allow_other_host: true
    else
      @controller.redirect_to @controller.update_person_info_people_path(ref: redirect_url(url)), status: :see_other
    end
  end

  def invalid_one_time_password
    @controller.flash.now[:error] = I18n.t('validate_otp.invalid_otp')
  end

  def service_not_allowed(service)
    assign(:service, service)
    @controller.render 'service_not_allowed', status: 403
  end
end
