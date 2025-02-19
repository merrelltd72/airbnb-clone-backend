# frozen_string_literal: true

require 'rails_helper'
require './app/controllers/users_controller'

RSpec.describe UsersController, type: :controller do
  describe 'Post #create' do
  let(:valid_attributes) do
    { use_route: '/users',  'name' => 'John Doe', 'email' => 'john@example.com', 'password' => 'password123', 'password_confirmation' => 'password123' }
  end
    it 'creates a new user' do
      expect {
      post :create, params: valid_attributes
    }.to change(User, :count).by(1)
      end
    end

    it 'returns a success message' do
      post :create, params: { use_route: '/users',  'name' => 'John Doe', 'email' => 'john@example.com', 'password' => 'password123', 'password_confirmation' => 'password123' }
      expect(response.status).to eq(201)
      expect(response.body).to include('User created successfully')
    end
  end
