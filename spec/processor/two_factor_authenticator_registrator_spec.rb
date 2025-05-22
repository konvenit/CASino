require 'spec_helper'

describe CASino::TwoFactorAuthenticatorRegistratorProcessor do
  describe '#process' do
    let(:listener) { Struct.new(:controller).new(controller: Object.new) }
    let(:processor) { described_class.new(listener) }
    let(:cookies) { { tgt: tgt } }
    let(:ticket_granting_ticket) { FactoryBot.create :ticket_granting_ticket }
    let(:user) { ticket_granting_ticket.user }
    let(:tgt) { ticket_granting_ticket.ticket }
    let(:user_agent) { ticket_granting_ticket.user_agent }

    before(:each) do
      listener.stub(:user_not_logged_in)
      listener.stub(:two_factor_authenticator_registered)
      allow(Person).to receive(:find).and_return(OpenStruct.new(allow_2fa_auth?: true, session_token: "01234567899876543210"))
    end

    it 'creates exactly one authenticator' do
      expect do
        processor.process(user)
      end.to change(CASino::TwoFactorAuthenticator, :count).by(1)
    end

    it 'calls #two_factor_authenticator_created on the listener' do
      listener.should_receive(:two_factor_authenticator_registered) do |authenticator|
        authenticator.should == CASino::TwoFactorAuthenticator.last
      end
      processor.process(user)
    end
  end
end