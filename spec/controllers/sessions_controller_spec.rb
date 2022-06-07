require 'spec_helper'

describe CASino::SessionsController do
  routes { CASino::Engine.routes }

  describe 'GET "new"' do
    it 'calls the process method of the LoginCredentialRequestor' do
      CASino::LoginCredentialRequestorProcessor.any_instance.should_receive(:process)
      get :new
    end
  end

  describe 'POST "create"' do
    it 'calls the process method of the LoginCredentialAcceptor' do
      CASino::LoginCredentialAcceptorProcessor.any_instance.should_receive(:process) do
        @controller.render body: nil
      end
      post :create
    end
  end

  describe 'POST "validate_otp"' do
    it 'calls the process method of the SecondFactorAuthenticatonAcceptor' do
      CASino::SecondFactorAuthenticationAcceptorProcessor.any_instance.should_receive(:process) do
        @controller.render body: nil
      end
      post :validate_otp
    end
  end

  describe 'GET "logout"' do
    it 'calls the process method of the Logout processor' do
      CASino::LogoutProcessor.any_instance.should_receive(:process) do |params, cookies, user_agent|
        params.should == controller.params
        cookies.should == controller.cookies
        user_agent.should == request.user_agent
      end
      get :logout
    end
  end

  describe 'GET "index"' do
    it 'calls the process method of the SessionOverview processor' do
      CASino::TwoFactorAuthenticatorOverviewProcessor.any_instance.should_receive(:process)
      CASino::SessionOverviewProcessor.any_instance.should_receive(:process)
      get :index
    end
  end

  describe 'DELETE "destroy"' do
    let(:id) { '123' }
    let(:tgt) { 'TGT-foobar' }
    it 'calls the process method of the SessionOverview processor' do
      request.cookies[:tgt] = tgt
      CASino::SessionDestroyerProcessor.any_instance.should_receive(:process) do |params, cookies, user_agent|
        params[:id].should == id
        cookies[:tgt].should == tgt
        user_agent.should == request.user_agent
        @controller.render body: nil
      end
      delete :destroy, params: { id: id }
    end
  end

  describe 'GET "destroy_others"' do
    it 'calls the process method of the OtherSessionsDestroyer' do
      CASino::OtherSessionsDestroyerProcessor.any_instance.should_receive(:process) do
        @controller.render body: nil
      end
      get :destroy_others
    end
  end
end
