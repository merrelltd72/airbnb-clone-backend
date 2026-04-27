require 'rails_helper'

RSpec.describe "Passwords", type: :request do
  describe "GET /forgot" do
    it "returns http success" do
      get "/passwords/forgot"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /reset" do
    it "returns http success" do
      get "/passwords/reset"
      expect(response).to have_http_status(:success)
    end
  end

end
