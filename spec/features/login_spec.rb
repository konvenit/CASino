require 'spec_helper'

describe 'Login' do
  include CASino::Engine.routes.url_helpers
  let(:otp) { '123456' }

  before { page.driver.header 'Accept-Language', 'de' }

  subject { page }

  context 'with two-factor authentication enabled' do
    before do
      allow(Person).to receive(:find).and_return(OpenStruct.new(allow_2fa_auth?: true))
      stub_const("Proxies::LoginOTP", Class.new)
      stub_const("Notifikator", Class.new)
      allow(Proxies::LoginOTP).to receive(:new).and_return(OpenStruct.new(otp: "898989", person_id: 123))
      allow(Notifikator).to receive(:generate)
    end

    context 'with valid username and password' do
      before { sign_in }

      it { should_not have_button('Login') }
      it { should have_content('Zwei-Faktor-Authentifizierung') }
      it { should have_content('Code') }
      it { should have_button('Fortfahren') }

      context 'when filling in the correct otp' do
        before do
          ROTP::TOTP.any_instance.should_receive(:verify).with(otp).and_return(true)
          fill_in :otp, with: otp
          click_button 'Fortfahren'
        end

        it { should_not have_button('Login') }
        it { should_not have_button('Fortfahren') }
        its(:current_path) { should == sessions_path }
      end

      context 'when filling in an incorrect otp' do
        before do
          ROTP::TOTP.any_instance.should_receive(:verify).with(otp).and_return(false)
          fill_in :otp, with: otp
          click_button 'Fortfahren'
        end

        it { should have_text('Das eingegebene Einmalkennwort ist ungültig.') }
        it { should have_button('Fortfahren') }
      end
    end
  end

  context 'with two-factor authentication disabled' do
    before { allow(Person).to receive(:find).and_return(OpenStruct.new(allow_2fa_auth?: false)) }

    context 'with valid username and password' do
      before { sign_in }

      it { should_not have_button('Login') }
      its(:current_path) { should == sessions_path }
    end
  end

  context 'with invalid username' do
    before { sign_in username: 'lalala', password: 'foobar123' }

    it { should have_button('Login') }
    it { should have_text('Falscher Benutzername oder falsches Passwort, oder Ihr Konto wurde gesperrt, nachdem zu oft ein falsches Passwort eingegeben wurde.') }
  end

  context 'with blank password' do
    before { sign_in password: '' }

    it { should have_button('Login') }
    it { should have_text('Falscher Benutzername oder falsches Passwort, oder Ihr Konto wurde gesperrt, nachdem zu oft ein falsches Passwort eingegeben wurde.') }
  end
end
