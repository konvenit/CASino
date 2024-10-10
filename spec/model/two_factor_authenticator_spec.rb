require 'spec_helper'

describe CASino::TwoFactorAuthenticator do
  describe '.cleanup' do
    it 'deletes expired two-factor authenticators' do
      authenticator = FactoryBot.create :two_factor_authenticator
      authenticator.created_at = 10.hours.ago
      authenticator.save!
      expect do
        described_class.cleanup
      end.to change(described_class, :count).by(-1)
    end

    it 'does not delete non-expired two-factor authenticators' do
      authenticator = FactoryBot.create :two_factor_authenticator
      authenticator.created_at = (CASino.config.two_factor_authenticator[:lifetime].seconds - 5).ago
      expect do
        described_class.cleanup
      end.to change(described_class, :count).by(0)
    end
  end

  describe '.expired?' do
    it 'returns true if expired' do
      authenticator = FactoryBot.create :two_factor_authenticator
      authenticator.created_at = (CASino::TwoFactorAuthenticator.lifetime + 10).ago
      authenticator.save!
      expect(authenticator.expired?).to be_truthy
    end

    it 'returns false if not expired' do
      authenticator = FactoryBot.create :two_factor_authenticator
      authenticator.created_at = (CASino::TwoFactorAuthenticator.lifetime - 10).ago
      authenticator.save!
      expect(authenticator.expired?).to be_falsey
    end
  end
end
