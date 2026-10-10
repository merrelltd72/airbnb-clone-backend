require "rails_helper"

RSpec.describe PasswordResetMailer, type: :mailer do
  describe "#password_reset" do
    let(:user) { create(:user, name: "Ada", email: "ada@example.com") }
    let(:token) { "raw token/with+chars" }
    let(:mail) { described_class.with(user: user, token: token).password_reset }

    it "renders the headers" do
      expect(mail.subject).to eq("Password Reset")
      expect(mail.to).to eq([ "ada@example.com" ])
      expect(mail.from).to eq([ ENV.fetch("MAILER_FROM", "no-reply@example.com") ])
    end

    it "includes the greeting and a URL-encoded reset link" do
      body = mail.text_part.body.decoded

      expect(body).to include("Hello Ada")
      expect(body).to include("/reset-password?token=#{ERB::Util.url_encode(token)}")
    end
  end
end
