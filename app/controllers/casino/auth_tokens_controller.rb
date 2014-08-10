class CASino::AuthTokensController < CASino::ApplicationController
  before_action :validate_auth_token_signature, :validate_auth_token_ticket

  def login
    raise "#{auth_token_data[:username]} logged in successfully"
  end

  private
  def validate_auth_token_signature
    digest = OpenSSL::Digest::SHA256.new
    Dir.glob(Rails.root.join('config/auth_token_signers/*.pem')) do |file|
      key = OpenSSL::PKey::RSA.new File.read(file)
      if key.verify(digest, auth_token_signature, auth_token)
        logger.info "Successfully validated auth token signature with #{file}"
        return true
      end
    end
    logger.info 'Auth token signature is not valid'
    redirect_to_login
  end

  def validate_auth_token_ticket
    unless auth_token_ticket_valid?(auth_token_data[:ticket])
      redirect_to_login
    end
  end

  def redirect_to_login
    redirect_to login_path(service: params[:service])
  end

  def auth_token_signature
    @auth_token_signature ||= base64_decode(params[:ats])
  end

  def auth_token
    @auth_token ||= base64_decode(params[:at])
  end

  def base64_decode(data)
    return '' if data.nil?
    begin
      Base64.strict_decode64(data)
    rescue
      ''
    end
  end

  def auth_token_data
    JSON.parse(auth_token).symbolize_keys
  end

  def auth_token_ticket_valid?(auth_token_ticket)
    CASino::AuthTokenTicket.consume(auth_token_ticket)
  end
end
