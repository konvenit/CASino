require 'spec_helper'

describe CASino::TwoFactorAuthenticatorOverviewListener do
  include CASino::Engine.routes.url_helpers
  let(:controller) { Struct.new(:cookies).new(cookies: {}) }
  let(:listener) { described_class.new(controller) }

  describe '#two_factor_authenticator_found' do
    let(:two_factor_authenticator) { Object.new }

    it 'assigns the two-factor authenticator' do
      listener.two_factor_authenticator_found(two_factor_authenticator)
      controller.instance_variable_get(:@two_factor_authenticator).should == two_factor_authenticator
    end
  end
end
