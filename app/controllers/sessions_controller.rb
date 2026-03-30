class SessionsController < ApplicationController
  include JwtTokenConcern

  skip_before_action :authenticate_user!, only: [ :create, :destroy ]

  # Create user login session
  def create
    user = User.find_by(email: params[:email].to_s.strip.downcase)
    if user&.authenticate(params[:password])
      jwt = generate_jwt_token(user)
      cookies.signed[:jwt] = jwt_cookie_options.merge(value: jwt)
      render json: { email: user.email, user_id: user.id }, status: :ok
    else
      render json: {}, status: :unauthorized
    end
  end

  # Delete user login session
  def destroy
    cookies.delete(:jwt, jwt_cookie_delete_options)
    render json: { message: "Logged out successfully" }
  end

  private

  def jwt_cookie_options
    {
      httponly: true,
      expires: 24.hours.from_now,
      secure: Rails.env.production?,
      same_site: :lax
    }
  end

  def jwt_cookie_delete_options
    jwt_cookie_options.except(:expires)
  end
end
