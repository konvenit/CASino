class CASino::SessionsController < CASino::ApplicationController
  include CASino::SessionsHelper

  rate_limit to: 5, within: 5.minutes, with: -> { render_429("validate_otp") }, only: :validate_otp

  def index
    processor(:SessionOverview).process(cookies, request.user_agent)
  end

  def new
    processor(:LoginCredentialRequestor).process(params, cookies, request.user_agent)
  end

  def new_ticket
    new
    render :text => @login_ticket.ticket
  end

  def create
    processor(:LoginCredentialAcceptor).process(params, request.user_agent)
  end

  def destroy
    processor(:SessionDestroyer).process(params, cookies, request.user_agent)
  end

  def destroy_others
    processor(:OtherSessionsDestroyer).process(params, cookies, request.user_agent)
  end

  def logout
    processor(:Logout).process(params, cookies, request.user_agent)
  end

  def validate_otp
    processor(:TwoFactorAuthenticationAcceptor).process(params, request.user_agent)
  end
end
