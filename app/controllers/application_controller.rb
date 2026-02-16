class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  protect_from_forgery with: :exception, unless: -> { request.format.json? }

  require_relative "controllers/concerns/authentication_concern"

  include AuthenticationConcerns

  # Backend user authentication helper methods
  def current_user
    @current_user
  end

  private

  def set_current_user
    @current_user = current_user
  end

  def require_login
    redirect_to login_url, alert: "Please log in first" unless current_user
  end

  def require_admin
    redirect_to root_url, alert: "You must be an admin to access this page." unless current_user&.admin?
  end
end
