require "spec_helper"

describe CASino::ApplicationController, type: :controller do
  controller(CASino::ApplicationController) do
    def index
      head :ok
    end
  end

  before do
    @original_available_locales = I18n.available_locales
    @original_default_locale = I18n.default_locale
    I18n.available_locales = %i[de en fr]
    I18n.default_locale = :de
    allow(Rails.env).to receive(:test?).and_return(false)
  end

  after do
    I18n.available_locales = @original_available_locales
    I18n.default_locale = @original_default_locale
  end

  describe "#set_locale" do
    context "without a service param or an Accept-Language header" do
      it "falls back to the default locale" do
        get :index
        expect(I18n.locale).to eq(:de)
      end
    end

    context "with a supported locale in the service param" do
      it "uses the service-param locale" do
        get :index, params: { service: "https://example.com/foo?locale=fr" }
        expect(I18n.locale).to eq(:fr)
      end
    end

    context "with an unsupported locale in the service param" do
      it "falls back to the default locale" do
        get :index, params: { service: "https://example.com/foo?locale=es" }
        expect(I18n.locale).to eq(:de)
      end
    end

    context "with a regional variant in the service param" do
      it "matches the base language" do
        get :index, params: { service: "https://example.com/foo?locale=de-AT" }
        expect(I18n.locale).to eq(:de)
      end
    end

    context "with a supported language in the Accept-Language header" do
      it "uses that language" do
        request.env["HTTP_ACCEPT_LANGUAGE"] = "fr-FR,fr;q=0.9,en;q=0.8"
        get :index
        expect(I18n.locale).to eq(:fr)
      end
    end

    context "with a regional variant in the Accept-Language header" do
      it "matches the base language" do
        request.env["HTTP_ACCEPT_LANGUAGE"] = "de-CH,de;q=0.9"
        get :index
        expect(I18n.locale).to eq(:de)
      end
    end

    context "with an unsupported language in the Accept-Language header" do
      it "falls back to the default locale" do
        request.env["HTTP_ACCEPT_LANGUAGE"] = "es-ES,es;q=0.9"
        get :index
        expect(I18n.locale).to eq(:de)
      end
    end

    context "with both a service param and an Accept-Language header set" do
      it "prefers the service-param locale" do
        request.env["HTTP_ACCEPT_LANGUAGE"] = "fr-FR"
        get :index, params: { service: "https://example.com/foo?locale=en" }
        expect(I18n.locale).to eq(:en)
      end
    end
  end
end
