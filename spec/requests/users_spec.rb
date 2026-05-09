# spec/requests/users_spec.rb
require "rails_helper"

RSpec.describe "Users", type: :request do
  let(:json_headers) do
    {
      "ACCEPT" => "application/json",
      "CONTENT_TYPE" => "application/json"
    }
  end

  describe "POST /signup" do
    let(:valid_params) do
      {
        name: "Test User",
        email: "test@example.com",
        password: "Password123!",
        password_confirmation: "Password123!"
      }
    end

    it "creates a user and returns safe fields" do
      expect do
        post "/signup", params: valid_params.to_json, headers: json_headers
      end.to change(User, :count).by(1)

      expect(response).to have_http_status(:created)
      body = JSON.parse(response.body)

      expect(body.keys).to include("id", "name", "email", "role", "created_at")
      expect(body.keys).not_to include(
        "password",
        "password_confirmation",
        "password_digest",
        "reset_password_token_digest"
      )
    end

    it "returns conflict for duplicate email" do
      User.create!(valid_params)

      post "/signup", params: valid_params.to_json, headers: json_headers

      expect(response).to have_http_status(:conflict)
    end

    it "returns unprocessable_entity for invalid payload" do
      post "/signup",
           params: { name: "", email: "", password: "x", password_confirmation: "y" }.to_json,
           headers: json_headers

      expect(response).to have_http_status(:unprocessable_entity)
      body = JSON.parse(response.body)
      expect(body["errors"]).to be_present
    end
  end
end
