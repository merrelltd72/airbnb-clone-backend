class SessionsController < ApplicationController
  # Create user login session
  def create
    user = User.find_by(email: params[:email])
    if user && user.authenticate(params[:password])
      jwt = generate_jwt_token(user)
      cookies.signed[:jwt] = { value: jwt, httponly: true }
      render json: { email: user.email, user_id: user.id }, status: :created
    else
      render json: {}, status: :unauthorized
    end
  end

  # Delete user login session
  def destroy
    cookies.delete(:jwt)
    render json: { message: "Logged out successfully" }
  end

  private

  def generate_jwt_token(user)
    JWT.encode(
        {
          user_id: user.id, # the data to encode
          exp: 24.hours.from.now.to_i # the expiration time
        },
        Rails.application.credentials.fetch(:secret_key_base), # the secret key
        "HS256" # the encryption algorithm
      )
  end
end
