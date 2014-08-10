class CASino::AuthTokenValidatorService
  AUTH_TOKEN_SIGNERS_GLOB = Rails.root.join('config/auth_token_signers/*.pem').freeze

  attr_reader :token, :signature

  def initialize(token, signature)
    @token = token
    @signature = signature
  end

  def extract_user
    return false unless signature_valid?
    return false unless ticket_valid?
    raise "#{token_data[:username]} logged in successfully"
  end

  def token_data
    begin
      JSON.parse(token).symbolize_keys
    rescue
      {}
    end
  end

  private
  def signature_valid?
    digest = OpenSSL::Digest::SHA256.new
    Dir.glob(AUTH_TOKEN_SIGNERS_GLOB) do |file|
      key = OpenSSL::PKey::RSA.new(File.read(file))
      if key.verify(digest, signature, token)
        Rails.logger.info("Successfully validated auth token signature with #{file}")
        return true
      end
    end
    false
  end

  def ticket_valid?
    CASino::AuthTokenTicket.consume(token_data[:ticket])
  end
end
