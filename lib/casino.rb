require 'active_support/configurable'
require 'casino/engine'

# resque incompatibility workaround
class ApplicationController < ActionController::Base

end

module CASino
  module Api
    module V1

    end
  end

  module API

  end
end

def current_path
  File.dirname(__FILE__)
end

# remove .rb extension and require
def include_file(name)
  name = name.sub(current_path, '')
  require File.join(current_path, File.dirname(name), File.basename(name, '.rb'))
end

Dir.glob(File.join(current_path, '../app/helpers', '**/*.rb')).sort.each do |file|
  include_file file
end

include_file File.join(current_path, '../app/models/casino/validation_result')

include_file File.join(current_path, '../app/processors/casino/processor_concern/tickets')
include_file File.join(current_path, '../app/processors/casino/processor_concern/proxy_tickets')
include_file File.join(current_path, '../app/processors/casino/processor_concern/service_tickets')

Dir.glob(File.join(current_path, '../app/processors/casino/processor_concern', '**/*.rb')).sort.each do |file|
  include_file file
end

include_file File.join(current_path, '../app/processors/casino/processor')
include_file File.join(current_path, '../app/processors/casino/service_ticket_validator_processor')

include_file File.join(current_path, '../app/controllers/casino/application_controller')
# end resque incompatibility workaround

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
      timeout: 180,
      lifetime_inactive: 300,
      drift: 30
    }
  }

  self.config.merge! defaults.deep_dup
end