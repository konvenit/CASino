require 'spec_helper'

describe CASino::ProxyTicketsController do
  routes { CASino::Engine.routes }

  describe 'GET "serviceValidate"' do
    let(:params) { { service: 'https://www.example.com/' } }
    it 'calls the process method of the ProxyTicketValidator' do
      CASino::ProxyTicketValidatorProcessor.any_instance.should_receive(:process).with(kind_of(ActionController::Parameters)) do |params|
        params.should == controller.params
        controller.render body: nil
      end
      get :proxy_validate, params: params
    end
  end

  describe 'GET "proxy"' do
    let(:params) { { service: 'https://www.example.com/' } }
    it 'calls the process method of the ProxyTicketProvider' do
      CASino::ProxyTicketProviderProcessor.any_instance.should_receive(:process).with(kind_of(ActionController::Parameters)) do |params|
        params.should == controller.params
        controller.render body: nil
      end
      get :create, params: params
    end
  end
end
