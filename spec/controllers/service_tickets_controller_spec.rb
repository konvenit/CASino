require 'spec_helper'

describe CASino::ServiceTicketsController do
  routes { CASino::Engine.routes }

  describe 'GET "validate"' do
    let(:params) { { service: 'https://www.example.com/' } }
    it 'calls the process method of the LegacyValidator' do
      CASino::LegacyValidatorProcessor.any_instance.should_receive(:process).with(kind_of(ActionController::Parameters)) do |params|
        params.should == controller.params
        controller.render body: nil
      end
      get :validate, params: params
    end
  end

  describe 'GET "serviceValidate"' do
    let(:params) { { service: 'https://www.example.com/' } }
    it 'calls the process method of the LegacyValidator' do
      CASino::ServiceTicketValidatorProcessor.any_instance.should_receive(:process).with(kind_of(ActionController::Parameters)) do |params|
        params.should == controller.params
        controller.render body: nil
      end
      get :service_validate, params: params
    end
  end
end
