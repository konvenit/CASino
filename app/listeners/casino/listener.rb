module CASino
  class Listener

    # include helpers to have the route path methods (like sessions_path)
    include CASino::Engine.routes.url_helpers

    def initialize(controller)
      @controller = controller
    end

    def password_expired(url, ticket_granting_ticket, cookie_expiry_time = nil)
      if @controller.password_expiration_enabled?
        @controller.redirect_to "/password_updates/new?#{{ tgt: ticket_granting_ticket, expires: cookie_expiry_time, service: @controller.params[:service] }.to_query}"
      else
        @controller.prolong_expiration_period ticket_granting_ticket
        user_logged_in url, ticket_granting_ticket, cookie_expiry_time
      end
    end

    protected
    def assign(name, value)
      @controller.instance_variable_set("@#{name}", value)
    end
  end
end
