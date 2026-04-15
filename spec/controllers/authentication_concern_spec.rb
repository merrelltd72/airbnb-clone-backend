require "rails_helper"

RSpec.describe "AuthenticationConcern", type: :controller do
  controller(ActionController::Base) do
    include AuthenticationConcern

    def index
      render json: { user_id: current_user.id }
    end
  end

  let(:secret) do
    Rails.application.credentials[:secret_key_base] || Rails.application.secret_key_base
  end
  let!(:user) do
    User.create!(
      name: "Auth Test",
      email: "auth_test@example.com",
      password: "password123",
      password_confirmation: "password123"
    )
  end

  before do
    routes.draw { get "index" => "anonymous#index" }
  end

  def jwt_for(user_id:, exp:)
    JWT.encode({ user_id: user_id, exp: exp.to_i }, secret, "HS256")
  end

  it "returns 401 when no jwt cookie is present" do
    get :index

    expect(response).to have_http_status(:unauthorized)
    expect(JSON.parse(response.body)).to eq("error" => "Unauthorized")
  end

  it "allows access with a valid jwt cookie" do
    token = jwt_for(user_id: user.id, exp: 24.hours.from_now)
    cookies.signed[:jwt] = token

    get :index

    expect(response).to have_http_status(:ok)
    expect(JSON.parse(response.body)).to eq("user_id" => user.id)
  end

  it "returns 401 when token is expired" do
    token = jwt_for(user_id: user.id, exp: 1.hour.ago)
    cookies.signed[:jwt] = token

    get :index

    expect(response).to have_http_status(:unauthorized)
  end

  it "returns 401 when token is malformed" do
    cookies.signed[:jwt] = "not-a-real-jwt"

    get :index

    expect(response).to have_http_status(:unauthorized)
  end

  it "returns 401 when user in token does not exist" do
    token = jwt_for(user_id: -999, exp: 24.hours.from_now)
    cookies.signed[:jwt] = token

    get :index

    expect(response).to have_http_status(:unauthorized)
  end
end
