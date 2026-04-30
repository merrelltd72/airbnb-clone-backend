require 'rails_helper'

RSpec.describe "Me", type: :request do
  let(:json_headers) { { "ACCEPT" => "application/json", "CONTENT_TYPE" => "application/json" } }

  let!(:user) do
    User.create!(
      name: "Me User",
      email: "me@example.com",
      password: "Password123!",
      password_confirmation: "Password123!"
    )
  end

  def auth_cookie_for(user, password: "Password123!")
    post "/sessions.json",
      params: { email: user.email, password: password }.to_json,
      headers: json_headers
    response.headers["Set-Cookie"]
  end

  it "returns 401 when unauthenticated" do
    get "/me.json", headers: { "ACCEPT" => "application/json" }
    expect(response).to have_http_status(:unauthorized)
  end

  it "returns current user when authenticated" do
    cookie = auth_cookie_for(user)
    get "/me.json", headers: { "ACCEPT" => "application/json", "Cookie" => cookie }

    expect(response).to have_http_status(:ok)
    body = JSON.parse(response.body)
    expect(body["email"]).to eq(user.email)
  end

  it "updates profile fields only" do
    cookie = auth_cookie_for(user)

    patch "/me.json",
      params: { name: "Updated", image: "https://example.com/avatar.png", role: "maintainer" }.to_json,
      headers: json_headers.merge("Cookie" => cookie)

    expect(response).to have_http_status(:ok)
    expect(user.reload.name).to eq("Updated")
    expect(user.role).not_to eq("maintainer")
  end

  it "updates password with correct current password" do
    cookie = auth_cookie_for(user)

    patch "/me/password.json",
      params: {
        current_password: "Password123!",
        new_password: "NewPassword123!",
        new_password_confirmation: "NewPassword123!"
      }.to_json,
      headers: json_headers.merge("Cookie" => cookie)

    expect(response).to have_http_status(:ok)
    expect(user.reload.authenticate("NewPassword123!")).to be_present
  end
end
