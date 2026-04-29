require 'rails_helper'

RSpec.describe "Passwords", type: :request do
  let(:json_headers) { { "CONTENT_TYPE" => "application/json", "ACCEPT" => "application/json" } }

  let(:user) do
    User.create!(
      name: "Reset User",
      email: "reset@example.com",
      password: "password",
      password_confirmation: "password"
    )
  end

  it "forgot returns generic success for existing email" do
    post "/password/forgot.json",
    params: { email: user.email }.to_json,
    headers: json_headers

    expect(response).to have_http_status(:ok)
    expect(JSON.parse(response.body)["message"]).to be_present
  end

  it "forgot returns generic success for unknown email" do
    post "/password/forgot.json",
      params: { email: "unknown@example.com" }.to_json,
      headers: json_headers

    expect(response).to have_http_status(:ok)
    expect(JSON.parse(response.body)["message"]).to be_present
  end

  it "reset returns success for valid token" do
    token = user.generate_reset_password_token!
    post "/password/reset.json",
    params: {
      token: token,
      new_password: "NewPassword123!",
      new_password_confirmation: "NewPassword123!"
    }.to_json,
    headers: json_headers

    expect(response).to have_http_status(:ok)
    expect(JSON.parse(response.body)["message"]).to be_present
  end

  it "reset rejects invalid token" do
    post "/password/reset.json",
      params: {
        token: "bad-token",
        new_password: "NewPassword123!",
        new_password_confirmation: "NewPassword123!"
      }.to_json,
      headers: json_headers

    expect(response).to have_http_status(:bad_request)
  end
end
