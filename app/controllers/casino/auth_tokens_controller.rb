class CASino::AuthTokensController < CASino::ApplicationController
  def login
    user = validator_service.extract_user
    redirect_to_login unless user
  end

  private
  def validator_service
    @validator_service ||= CASino::AuthTokenValidatorService.new(auth_token, auth_token_signature)
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
    begin
      Base64.strict_decode64(data)
    rescue
      ''
    end
  end
end
