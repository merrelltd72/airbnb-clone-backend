module AuthenticationConcern
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_user!
  end

  def current_user
    token = cookies.signed[:jwt]
    return unless token

    decoded_token = decode_jwt_token(token)
    return unless decoded_token

    User.find_by(id: decoded_token[0]["user_id"])
  end

  private

  def decode_jwt_token(token)
    JWT.decode(
      token,
      jwt_secret_key,
      true,
      { algorithm: "HS256" }
    )
  rescue JWT::DecodeError
    nil
  end

  def jwt_secret_key
    Rails.application.credentials[:secret_key_base] || Rails.application.secret_key_base
  end

  def authenticate_user!
    render json: { error: "Unauthorized" }, status: :unauthorized unless current_user
  end
end
