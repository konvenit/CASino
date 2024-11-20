require 'spec_helper'

describe CASino::TwoFactorAuthenticator do
  describe '.cleanup' do
    it 'deletes expired two-factor authenticators' do
      authenticator = FactoryBot.create :two_factor_authenticator, expiry_at: 10.hours.ago
      expect do
        described_class.cleanup
      end.to change(described_class, :count).by(-1)
    end

    it 'does not delete non-expired two-factor authenticators' do
      authenticator = FactoryBot.create :two_factor_authenticator, expiry_at: 1.hour.from_now
      expect do
        described_class.cleanup
      end.to change(described_class, :count).by(0)
    end
  end

  describe '.expired?' do
    it 'returns true if expired' do
      authenticator = FactoryBot.create :two_factor_authenticator, expiry_at: 10.hours.ago
      expect(authenticator.expired?).to be_truthy
    end

    it 'returns false if not expired' do
      authenticator = FactoryBot.create :two_factor_authenticator, expiry_at: 1.hour.from_now
      expect(authenticator.expired?).to be_falsey
    end
  end
end
