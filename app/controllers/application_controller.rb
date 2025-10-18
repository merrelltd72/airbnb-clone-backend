class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  protect_from_forgery with: :exception, unless: -> { request.format.json? }

  # Backend user authentication helper methods
  def current_user
    token = cookies.signed[:jwt]
    return unless token

      begin
        decoded_token = generate_jwt_token(token)
        User.find_by(id: decoded_token[0]["user_id"])
      rescue JWT::ExpiredSignature
        nil
      end
  end

  def authenticate_user
    return if current_user

    rendor json: {}, status: :unauthorized
  end

  private

  def generate_jwt_token(token)
    JWT.decode(
          token,
          Rails.application.credentials.fetch(:secret_key_base),
          true,
          { algorithm: "HS256" }
        )
  end
end
