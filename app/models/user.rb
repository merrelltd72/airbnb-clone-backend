class User < ApplicationRecord
  has_secure_password

  enum :role, { guest: 0, host: 1, maintainer: 2 }, prefix: true

  validates :email, presence: true, uniqueness: { case_sensitive: false }
  validates :name, presence: true
  validates :role, presence: true

  MAX_FAILED_ATTEMPTS = 5

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
end
