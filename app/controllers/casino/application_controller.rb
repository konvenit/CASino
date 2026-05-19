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

  def set_locale
    detected = locale_from_service_param || locale_from_accept_language_header
    I18n.locale = supported_locale(detected) || I18n.default_locale
  end

  def locale_from_service_param
    return nil unless params[:service]

    match = params[:service].match(/[?&]locale=([^&]+)(&|$)/)
    match && match[1]
  end

  def locale_from_accept_language_header
    return nil unless request.env["HTTP_ACCEPT_LANGUAGE"]
    return "de" if Rails.env.test?

    http_accept_language.compatible_language_from(I18n.available_locales)
  end

  def supported_locale(locale)
    return nil if locale.blank?

    base = locale.to_s.split(/[-_]/).first.downcase.to_sym
    I18n.available_locales.include?(base) ? base : nil
  end

  def http_accept_language
    HttpAcceptLanguage::Parser.new(request.env["HTTP_ACCEPT_LANGUAGE"])
  end

  def missing_template(exception)
    render plain: 'Format not supported', status: :not_acceptable
  end
end
