# spec/requests/passwords_spec.rb
require "rails_helper"

RSpec.describe "Passwords", type: :request do
  let(:json_headers) do
    {
      "ACCEPT" => "application/json",
      "CONTENT_TYPE" => "application/json"
    }
  end

  let!(:user) do
    User.create!(
      name: "Reset User",
      email: "reset@example.com",
      password: "Password123!",
      password_confirmation: "Password123!"
    )
  end

  describe "POST /password/forgot" do
    it "returns generic success for existing email and stores digest/timestamp" do
      post "/password/forgot",
           params: { email: user.email }.to_json,
           headers: json_headers

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)).to eq(
        "message" => "If the email exists, reset instructions have been sent."
      )

      user.reload
      expect(user.reset_password_token_digest).to be_present
      expect(user.reset_password_sent_at).to be_present
    end

    it "returns same generic success for unknown email" do
      post "/password/forgot",
           params: { email: "unknown@example.com" }.to_json,
           headers: json_headers

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)).to eq(
        "message" => "If the email exists, reset instructions have been sent."
      )
    end
  end

  describe "POST /password/reset" do
    it "resets password with a valid token and clears token fields" do
      token = user.generate_reset_password_token!

      post "/password/reset",
           params: {
             token: token,
             new_password: "NewPassword123!",
             new_password_confirmation: "NewPassword123!"
           }.to_json,
           headers: json_headers

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)).to eq(
        "message" => "Password has been reset successfully."
      )

      user.reload
      expect(user.reset_password_token_digest).to be_nil
      expect(user.reset_password_sent_at).to be_nil
      expect(user.authenticate("NewPassword123!")).to be_present
    end

    it "returns bad_request for invalid token" do
      post "/password/reset",
           params: {
             token: "invalid-token",
             new_password: "NewPassword123!",
             new_password_confirmation: "NewPassword123!"
           }.to_json,
           headers: json_headers

      expect(response).to have_http_status(:bad_request)
      expect(JSON.parse(response.body)).to eq("error" => "Invalid or expired token")
    end

    it "returns bad_request for expired token" do
      token = user.generate_reset_password_token!
      user.update!(reset_password_sent_at: 2.hours.ago)

      post "/password/reset",
           params: {
             token: token,
             new_password: "NewPassword123!",
             new_password_confirmation: "NewPassword123!"
           }.to_json,
           headers: json_headers

      expect(response).to have_http_status(:bad_request)
      expect(JSON.parse(response.body)).to eq("error" => "Invalid or expired token")
    end
  end
end
