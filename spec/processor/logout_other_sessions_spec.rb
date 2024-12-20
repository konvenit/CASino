require 'spec_helper'

describe CASino::OtherSessionsDestroyerProcessor do
  describe '#process' do
    let(:listener) { Struct.new(:controller).new(controller: Object.new) }
    let(:processor) { described_class.new(listener) }
    let(:cookies) { { tgt: tgt } }
    let(:url) { nil }
    let(:params) { { :service => url } unless url.nil? }

    before(:each) do
      listener.stub(:other_sessions_destroyed)
    end

    context 'with an existing ticket-granting ticket' do
      let(:user) { FactoryBot.create :user }
      let!(:other_users_ticket_granting_tickets) { FactoryBot.create_list :ticket_granting_ticket, 3 }
      let!(:other_ticket_granting_tickets) { FactoryBot.create_list :ticket_granting_ticket, 3, user: user }
      let!(:ticket_granting_ticket) { FactoryBot.create :ticket_granting_ticket, user: user }
      let(:tgt) { ticket_granting_ticket.ticket }
      let(:user_agent) { ticket_granting_ticket.user_agent }

      it 'deletes all other ticket-granting tickets' do
        expect do
          processor.process(params, cookies, user_agent)
        end.to change(CASino::TicketGrantingTicket, :count).by(-3)
      end

      it 'calls the #user_logged_out method on the listener' do
        listener.should_receive(:other_sessions_destroyed).with(nil)
        processor.process(params, cookies, user_agent)
      end

      context 'with an URL' do
        let(:url) { 'http://www.example.com' }

        it 'calls the #user_logged_out method on the listener and passes the URL' do
          listener.should_receive(:other_sessions_destroyed).with(url)
          processor.process(params, cookies, user_agent)
        end
      end
    end

    context 'with an invlaid ticket-granting ticket' do
      let(:tgt) { 'TGT-lalala' }

      it 'calls the #other_sessions_destroyed method on the listener' do
        listener.should_receive(:other_sessions_destroyed).with(nil)
        processor.process(params, cookies)
      end
    end
  end
end
