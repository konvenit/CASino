require 'spec_helper'

describe CASino::API::LogoutProcessor do
  describe '#process' do
    let(:listener) { Struct.new(:controller).new(controller: Object.new) }
    let(:processor) { described_class.new(listener) }

    context 'with an existing ticket-granting ticket' do
      let(:ticket_granting_ticket) { FactoryBot.create(:ticket_granting_ticket) }
      let(:user_agent) { ticket_granting_ticket.user_agent }

      it 'deletes the ticket-granting ticket' do
        listener.should_receive(:user_logged_out_via_api)
        processor.process(ticket_granting_ticket.ticket, user_agent)
        CASino::TicketGrantingTicket.where(id: ticket_granting_ticket.id).first.should == nil
      end

      it 'calls the #user_logged_out_via_api method on the listener' do
        listener.should_receive(:user_logged_out_via_api)
        processor.process(ticket_granting_ticket, user_agent)
      end

    end

    context 'with an invalid ticket-granting ticket' do
      let(:tgt) { 'TGT-lalala' }

      it 'calls the #user_logged_out method on the listener' do
        listener.should_receive(:user_logged_out_via_api)
        processor.process(tgt)
      end
    end
  end
end
