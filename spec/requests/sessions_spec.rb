# spec/requests/sessions_spec.rb
require "rails_helper"

RSpec.describe "Sessions", type: :request do
  let(:json_headers) do
    {
      "ACCEPT" => "application/json",
      "CONTENT_TYPE" => "application/json"
    }
  end

  let!(:user) do
    User.create!(
      name: "Login User",
      email: "login@example.com",
      password: "Password123!",
      password_confirmation: "Password123!"
    )
  end

  describe "POST /sessions" do
    it "logs in with valid credentials and sets jwt cookie" do
      post "/sessions",
           params: { email: user.email, password: "Password123!" }.to_json,
           headers: json_headers

      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body).to include("id" => user.id, "email" => user.email, "role" => user.role)
      expect(response.headers["Set-Cookie"]).to include("jwt=")
    end

    it "returns unauthorized for invalid password" do
      post "/sessions",
           params: { email: user.email, password: "wrong-pass" }.to_json,
           headers: json_headers

      expect(response).to have_http_status(:unauthorized)
    end

    it "returns locked when account is locked" do
      user.update!(locked_at: Time.current)

      post "/sessions",
           params: { email: user.email, password: "Password123!" }.to_json,
           headers: json_headers

      expect(response).to have_http_status(:locked)
    end

    it "increments failed attempts on invalid login" do
      expect do
        post "/sessions",
             params: { email: user.email, password: "wrong-pass" }.to_json,
             headers: json_headers
      end.to change { user.reload.failed_attempts }.by(1)
    end
  end

  describe "DELETE /sessions" do
    it "returns ok" do
      delete "/sessions", headers: { "ACCEPT" => "application/json" }
      expect(response).to have_http_status(:ok)
    end
  end
end
