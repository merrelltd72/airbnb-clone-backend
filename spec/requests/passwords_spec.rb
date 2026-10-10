# spec/requests/passwords_spec.rb
require "rails_helper"

RSpec.describe "Passwords", type: :request do
  describe "POST /password/forgot" do
    it "returns the generic message for an unknown email" do
      post "/password/forgot", params: { email: "nobody@example.com" }, as: :json

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body).to eq(
        "message" => "If the email exists, reset instructions have been sent."
      )
    end
  end

  describe "POST /password/reset" do
    it "rejects an invalid token" do
      post "/password/reset",
        params: { token: "bogus", new_password: "newpass123", new_password_confirmation: "newpass123" }, as: :json

      expect(response).to have_http_status(:bad_request)
      expect(response.parsed_body).to eq("error" => "Invalid or expired token")
    end
  end
end
