require 'active_support/configurable'
require 'casino/engine'

module CASino
  include ActiveSupport::Configurable

  defaults = {
    authenticators: HashWithIndifferentAccess.new,
    logger: Rails.logger,
    frontend: HashWithIndifferentAccess.new(
      sso_name: 'CASino',
      footer_text: 'Powered by <a href="http://rbcas.com/">CASino</a>'
    ),
    implementors: HashWithIndifferentAccess.new(
      login_ticket: nil,
      proxy_granting_ticket: nil,
      proxy_ticket: nil,
      service_rule: nil,
      service_ticket: nil,
      ticket_granting_ticket: nil,
      two_factor_authenticator: nil,
      user: nil
    ),
    login_ticket: {
      lifetime: 600
    },
    ticket_granting_ticket: {
      lifetime: 86400,
      lifetime_long_term: 864000
    },
    service_ticket: {
      lifetime_unconsumed: 300,
      lifetime_consumed: 86400,
      single_sign_out_notification: {
        timeout: 5
      }
    },
    proxy_ticket: {
      lifetime_unconsumed: 300,
      lifetime_consumed: 86400
    },
    two_factor_authenticator: {
      lifetime: 360,
      remember_me_period: 2592000 # 30 days
    }
  }

  self.config.merge! defaults.deep_dup
end