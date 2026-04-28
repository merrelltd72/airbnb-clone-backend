class PasswordResetMailer < ApplicationMailer
  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.password_reset_mailer.password_reset.subject
  #
  def password_reset
    @user = params[:user]
    @token = params[:token]
    @greeting = "Hi"

    frontend_url = ENV.fetch("FRONTEND_URL", "http://localhost:3000")
    @reset_url = "#{frontend_url}/reset-password?token=#{ERB::Util.url_encode(@token)}"

    mail(to: @user.email, subject: "Password Reset")
  end
end
