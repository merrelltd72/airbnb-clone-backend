# frozen_string_literal: true

require 'rails_helper'
require './app/controllers/users_controller'

RSpec.describe UsersController, type: :controller do
  describe 'Post #create' do
    it 'creates a new user' do
      post :create, params: { use_route: '/users',  name: 'John Doe', email: 'john@example.com', password: 'password123', password_confirmation: 'password123' }
      expect(response.status).to eq(201)
      end
    end
  end
