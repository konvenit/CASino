require 'spec_helper'

describe CASino::API::Resource::AuthTokenTickets do
  include Rack::Test::Methods

  describe 'POST /api/auth_token_tickets' do
    it 'creates an auth token ticket' do
      lambda do
        post '/api/auth_token_tickets'
      end.should change(CASino::AuthTokenTicket, :count).by(1)
    end

    describe 'JSON' do
      before(:each) do
        post '/api/auth_token_tickets'
      end
      let(:ticket) { CASino::AuthTokenTicket.last }
      subject { JSON.parse(last_response.body) }

      its(['ticket']) { should == ticket.ticket }
    end
  end
end
