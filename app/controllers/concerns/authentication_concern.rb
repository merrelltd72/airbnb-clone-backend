module AuthenticationConcern
  extend ActiveSupport::Concern

  included do
    include JwtTokenConcern
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

  def authenticate_user!
    render json: { error: "Unauthorized" }, status: :unauthorized unless current_user
  end
end
