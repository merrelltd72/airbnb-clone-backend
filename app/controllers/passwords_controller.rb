class PasswordsController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :forgot, :reset ]

  # POST /password/forgot
  def forgot
    email = params[:email].to_s.downcase.strip
    user = User.where("Lower(email) = ?", email).first

    if user
      raw_token = user.generate_reset_password_token!
      PasswordResetMailer.with(user:, raw_token:).password_reset.deliver_later
    end

    render json: { message: "If the email exists, reset instructions have been sent." }, status: :ok
  end

  # POST /password/reset
  def reset
    pr = reset_params
    user = User.find_by_reset_password_token(pr[:token])

    return render json: { error: "Invalid or expired token" }, status: :bad_request unless user

    if user.update(
      password: pr[:new_password],
      password_confirmation: pr[:new_password_confirmation]
      )
      user.clear_password_reset_token!
      render json: { message: "Password has been reset successfully." }, status: :ok
    else
      render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def reset_params
    params.permit(:token, :new_password, :new_password_confirmation)
  end
end
