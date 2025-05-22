module CASino
  class Listener

    # include helpers to have the route path methods (like sessions_path)
    include CASino::Engine.routes.url_helpers

    def initialize(controller)
      @controller = controller
    end

    def password_expired(url, ticket_granting_ticket, cookie_expiry_time = nil)
      Rails.logger.error "password expired"
      if @controller.password_expiration_enabled?
        @controller.redirect_to "/password_updates/new?#{{ tgt: ticket_granting_ticket, expires: cookie_expiry_time, service: @controller.params[:service] }.to_query}"
      else
        @controller.prolong_expiration_period ticket_granting_ticket
        user_logged_in url, ticket_granting_ticket, cookie_expiry_time
      end
    end

    def assign_session_token(person)
      if person.session_token.blank?
        begin
          person.update_column :session_token, SecureRandom.hex(64)
        rescue ActiveRecord::RecordNotUnique
          retry
        end
      end

      @controller.session[:session_token] = person.session_token
    end

    protected
    def assign(name, value)
      @controller.instance_variable_set("@#{name}", value)
    end
  end
end
