class SessionsController < ApplicationController
  include JwtTokenConcern

  skip_before_action :authenticate_user!, only: [ :create, :destroy ]

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
end
