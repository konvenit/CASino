require 'casino'
require 'http_accept_language'

class CASino::ApplicationController < ::ApplicationController
  include ApplicationHelper

  layout 'application'
  before_action :set_locale

  unless Rails.env.development?
    rescue_from ActionView::MissingTemplate, with: :missing_template
  end

  def cookies
    super
  end

  protected
  def processor(processor_name, listener_name = nil)
    listener_name ||= processor_name
    listener = CASino.const_get(:"#{listener_name}Listener").new(self)
    @processor = CASino.const_get(:"#{processor_name}Processor").new(listener)
  end

  def available_locale
    ['de','en']
  end

  def set_locale
    locale = if params[:service] and params[:service].match(/.*[?&]locale=([^&]+)(&|$)/)
               result = params[:service].match(/.*[?&]locale=([^&]+)(&|$)/)
               result[1]
             elsif request.env['HTTP_ACCEPT_LANGUAGE']
               Rails.env.test? ? "de" : http_accept_language.preferred_language_from(I18n.available_locales)
             end
    I18n.locale = available_locale.include?(locale) ? locale : I18n.default_locale
  end

  def extract_locale_from_accept_language_header
    if request.env['HTTP_ACCEPT_LANGUAGE']
      http_accept_language.preferred_language_from(I18n.available_locales)
    end
  end

  def http_accept_language
    HttpAcceptLanguage::Parser.new request.env['HTTP_ACCEPT_LANGUAGE']
  end

  def missing_template(exception)
    render plain: 'Format not supported', status: :not_acceptable
  end
end
