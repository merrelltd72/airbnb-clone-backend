require "rails_helper"

RSpec.describe "Auth API", type: :request do
  let(:json_headers) do
    {
      "ACCEPT" => "application/json",
      "CONTENT_TYPE" => "application/json"
    }
  end

  let!(:user) do
    User.create!(
      name: "Auth User",
      email: "auth@example.com",
      password: "Password123!",
      password_confirmation: "Password123!",
      image: "https://example.com/avatar.png"
    )
  end

  def login_as(current_user = user, password: "Password123!")
    post "/sessions",
         params: { email: current_user.email, password: password }.to_json,
         headers: json_headers
    expect(response).to have_http_status(:ok)
  end

  describe "Signup - POST /signup" do
    it "creates a user and returns safe fields" do
      expect do
        post "/signup",
             params: {
               name: "New User",
               email: "new@example.com",
               password: "Password123!",
               password_confirmation: "Password123!"
             }.to_json,
             headers: json_headers
      end.to change(User, :count).by(1)

      expect(response).to have_http_status(:created)
      body = JSON.parse(response.body)
      expect(body.keys).to include("id", "name", "email", "role", "created_at")
      expect(body.keys).not_to include("password", "password_confirmation", "password_digest", "reset_password_token_digest")
    end

    it "returns conflict for duplicate email" do
      post "/signup",
           params: {
             name: "Dup",
             email: user.email,
             password: "Password123!",
             password_confirmation: "Password123!"
           }.to_json,
           headers: json_headers

      expect(response).to have_http_status(:conflict).or have_http_status(:unprocessable_entity)
    end
  end

  describe "Sessions - POST/DELETE /sessions" do
    it "logs in and sets jwt cookie" do
      post "/sessions",
           params: { email: user.email, password: "Password123!" }.to_json,
           headers: json_headers

      expect(response).to have_http_status(:ok)
      expect(response.headers["Set-Cookie"]).to include("jwt=")
      expect(JSON.parse(response.body)).to include("id" => user.id, "email" => user.email, "role" => user.role)
    end

    it "returns unauthorized for bad credentials" do
      post "/sessions",
           params: { email: user.email, password: "wrong-pass" }.to_json,
           headers: json_headers

      expect(response).to have_http_status(:unauthorized)
    end

    it "returns locked for locked user" do
      user.update!(locked_at: Time.current)

      post "/sessions",
           params: { email: user.email, password: "Password123!" }.to_json,
           headers: json_headers

      expect(response).to have_http_status(:locked)
    end

    it "logs out safely" do
      delete "/sessions", headers: { "ACCEPT" => "application/json" }
      expect(response).to have_http_status(:ok)
    end
  end

  describe "Me - GET/PATCH /me and PATCH /me/password" do
    it "returns 401 when unauthenticated" do
      get "/me", headers: { "ACCEPT" => "application/json" }
      expect(response).to have_http_status(:unauthorized)
    end

    it "returns current user when authenticated" do
      login_as
      get "/me", headers: { "ACCEPT" => "application/json" }

      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body).to include("id" => user.id, "email" => user.email, "role" => user.role)
    end

    it "updates profile-only fields" do
      login_as
      patch "/me",
            params: { name: "Updated Name", image: "https://example.com/new.png", role: "maintainer" }.to_json,
            headers: json_headers

      expect(response).to have_http_status(:ok)
      user.reload
      expect(user.name).to eq("Updated Name")
      expect(user.image).to eq("https://example.com/new.png")
      expect(user.role).to eq("guest")
    end

    it "updates password with correct current password" do
      login_as
      patch "/me/password",
            params: {
              current_password: "Password123!",
              new_password: "NewPassword123!",
              new_password_confirmation: "NewPassword123!"
            }.to_json,
            headers: json_headers

      expect(response).to have_http_status(:ok)
      expect(user.reload.authenticate("NewPassword123!")).to be_present
    end

    it "returns 400 with wrong current password" do
      login_as
      patch "/me/password",
            params: {
              current_password: "WrongPassword",
              new_password: "NewPassword123!",
              new_password_confirmation: "NewPassword123!"
            }.to_json,
            headers: json_headers

      expect(response).to have_http_status(:bad_request)
    end
  end

  describe "Password Reset - POST /password/forgot and POST /password/reset" do
    it "forgot returns generic success for known email" do
      post "/password/forgot",
           params: { email: user.email }.to_json,
           headers: json_headers

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)).to eq("message" => "If the email exists, reset instructions have been sent.")
    end

    it "forgot returns same generic success for unknown email" do
      post "/password/forgot",
           params: { email: "missing@example.com" }.to_json,
           headers: json_headers

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)).to eq("message" => "If the email exists, reset instructions have been sent.")
    end

    it "resets password with valid token and clears reset fields" do
      token = user.generate_reset_password_token!

      post "/password/reset",
           params: {
             token: token,
             new_password: "BrandNew123!",
             new_password_confirmation: "BrandNew123!"
           }.to_json,
           headers: json_headers

      expect(response).to have_http_status(:ok)
      user.reload
      expect(user.authenticate("BrandNew123!")).to be_present
      expect(user.reset_password_token_digest).to be_nil
      expect(user.reset_password_sent_at).to be_nil
    end

    it "returns bad_request for invalid token" do
      post "/password/reset",
           params: {
             token: "invalid-token",
             new_password: "BrandNew123!",
             new_password_confirmation: "BrandNew123!"
           }.to_json,
           headers: json_headers

      expect(response).to have_http_status(:bad_request)
    end
  end
end
