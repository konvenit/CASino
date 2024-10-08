require 'spec_helper'

describe CASino::TwoFactorAuthenticator do
  describe '.cleanup' do
    it 'deletes expired two-factor authenticators' do
      authenticator = FactoryBot.create :two_factor_authenticator
      authenticator.created_at = 10.hours.ago
      authenticator.save!
      lambda do
        described_class.cleanup
      end.should change(described_class, :count).by(-1)
    end

    it 'does not delete non-expired two-factor authenticators' do
      authenticator = FactoryBot.create :two_factor_authenticator
      authenticator.created_at = (CASino.config.two_factor_authenticator[:lifetime].seconds - 5).ago
      lambda do
        described_class.cleanup
      end.should_not change(described_class, :count)
    end
  end
end
