require 'spec_helper'

describe CASino::Listener do
  include CASino::Engine.routes.url_helpers
  let(:controller) { OpenStruct.new(cookies: {}, params: { service: "service"}) }
  let(:listener) { described_class.new(controller) }

  describe '#password_expired' do
    let(:ticket_granting_ticket) { 'TGT-123' }
    let(:cookie_expiry_time)     { Time.zone.parse("2022-05-12") }
    let(:url) { 'http://www.example.com/?ticket=TGT-123' }

    context 'when password_expiration_enabled is true' do
      before { allow(controller).to receive(:password_expiration_enabled?).and_return true }

      it 'should redirect to password update' do
        expect(controller).to receive(:redirect_to).with("/password_updates/new?expires=&service=service&tgt=TGT-123")
        listener.password_expired(url, ticket_granting_ticket)
      end

      it 'should include cookie_expiry_time when exist' do
        expect(controller).to receive(:redirect_to).with(
          a_string_matching(%r{/password_updates/new\?expires=2022-05-12([^&]*)?&service=service&tgt=TGT-123})
        )
        listener.password_expired(url, ticket_granting_ticket, cookie_expiry_time)
      end
    end

    context 'when password_expiration_enabled is false' do
      before { allow(controller).to receive(:password_expiration_enabled?).and_return false }

      it 'should prolong_expiration_period and call user_logged_in' do
        expect(controller).to receive(:prolong_expiration_period).with("TGT-123")
        expect(listener).to receive(:user_logged_in).with("http://www.example.com/?ticket=TGT-123", "TGT-123", nil)
        listener.password_expired(url, ticket_granting_ticket)
      end

      it 'should include cookie_expiry_time when exist' do
        expect(controller).to receive(:prolong_expiration_period).with("TGT-123")
        expect(listener).to receive(:user_logged_in).with("http://www.example.com/?ticket=TGT-123", "TGT-123", cookie_expiry_time)
        listener.password_expired(url, ticket_granting_ticket, cookie_expiry_time)
      end
    end
  end
end
