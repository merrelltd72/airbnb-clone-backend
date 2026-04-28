require "securerandom"
require "digest"
class User < ApplicationRecord
  has_secure_password

  enum :role, { guest: 0, host: 1, maintainer: 2 }, prefix: true

  validates :email, presence: true, uniqueness: { case_sensitive: false }
  validates :name, presence: true
  validates :role, presence: true

  MAX_FAILED_ATTEMPTS = 5
  RESET_PASSWORD_TOKEN_TTL = 30.minutes

  def locked?
    locked_at.present? && locked_at > 15.minutes.ago
  end

  def lock_account!
    update_columns(locked_at: Time.current)
  end

  def unlock_account!
    update_columns(locked_at: nil, failed_attempts: 0)
  end

  def record_failed_attempt!
    increment!(:failed_attempts)
    lock_account! if failed_attempts >= MAX_FAILED_ATTEMPTS
  end

  def record_login!
    update_columns(last_login_at: Time.current, failed_attempts: 0)
  end

  def generate_reset_password_token!
    raw_token = SecureRandom.urlsafe_base64(32)

    update!(
      reset_password_token_digest: self.class.digest_token(raw_token),
      reset_password_sent_at: Time.current
    )
    raw_token
  end

  def clear_password_reset_token!
    update!(
      reset_password_token_digest: nil,
      reset_password_sent_at: nil
    )
  end

  def password_reset_token_valid?
    reset_password_sent_at.present? && reset_password_sent_at >= RESET_PASSWORD_TOKEN_TTL.ago
  end

  def self.find_by_reset_password_token(raw_token)
    return nil if raw_token.blank?

    digest = digest_token(raw_token)
    user = find_by(reset_password_token_digest: digest)

    return nil unless user&.password_reset_token_valid?
    user
  end

  def self.digest_token(raw_token)
    Digest::SHA256.hexdigest(raw_token.to_s)
  end
end
