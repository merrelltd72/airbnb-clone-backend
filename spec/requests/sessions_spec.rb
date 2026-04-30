require 'rails_helper'

RSpec.describe "Sessions", type: :request do
  let(:json_headers) { { "ACCEPT" => "application/json", "CONTENT_TYPE" => "application/json" } }

  let!(:user) do
    User.create!(
      name: "Login User",
      email: "login@example.com",
      password: "Password123!",
      password_confirmation: "Password123!"
    )
  end

  it "logs in with valid credentials and sets jwt cookie" do
    post "/sessions.json",
      params: { email: user.email, password: "Password123!" }.to_json,
      headers: json_headers

    expect(response).to have_http_status(:ok)
    expect(response.headers["Set-Cookie"]).to include("jwt")
    body = JSON.parse(response.body)
    expect(body.keys).to contain_exactly("id", "email", "role")
  end

  it "returns 401 for invalid password" do
    post "/sessions.json",
      params: { email: user.email, password: "wrong-pass" }.to_json,
      headers: json_headers

    expect(response).to have_http_status(:unauthorized)
  end

  it "returns 423 when account is locked" do
    user.update!(locked_at: Time.current)

    post "/sessions.json",
      params: { email: user.email, password: "Password123!" }.to_json,
      headers: json_headers

    expect(response).to have_http_status(:locked)
  end

  it "clears session cookie on logout" do
    delete "/sessions.json", headers: { "ACCEPT" => "application/json" }
    expect(response).to have_http_status(:ok)
  end
end
