# Preview all emails at http://localhost:3000/rails/mailers/password_reset_mailer
class PasswordResetMailerPreview < ActionMailer::Preview
  # Preview this email at http://localhost:3000/rails/mailers/password_reset_mailer/password_reset
  def password_reset
    PasswordResetMailer.with(user: User.first || User.new(name: "Preview", email: "preview@example.com"), token: "preview-token").password_reset
  end
end
