module JwtTokenConcern
  extend ActiveSupport::Concern

  private

  def generate_jwt_token(user)
    JWT.encode(
        {
          user_id: user.id, # the data to encode
          exp: 24.hours.from_now.to_i # the expiration time
        },
        jwt_secret_key, # the secret key
        "HS256" # the encryption algorithm
      )
  end

  def jwt_secret_key
    Rails.application.credentials[:secret_key_base] || Rails.application.secret_key_base
  end

  def encode_jwt_token(payload)
    JWT.encode(payload, jwt_secret_key, "HS256")
  end

  def decode_jwt_token(token)
    JWT.decode(token, jwt_secret_key, true, { algorithm: "HS256" })
  rescue JWT::DecodeError
    nil
  end
end
