require_relative 'listener'

class CASino::LegacyValidatorListener < CASino::Listener
  def validation_failed(text)
    @controller.render body: text, content_type: 'text/plain'
  end

  def validation_succeeded(text)
    @controller.render body: text, content_type: 'text/plain'
  end
end
