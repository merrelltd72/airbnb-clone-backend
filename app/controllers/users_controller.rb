class UsersController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :create ]

  # Create a new user
  def create
    user = create_new_user(params)
    if user.save
      render json: { id: user.id,
      name: user.name,
      email: user.email,
      role: user.role,
      created_at: user.created_at }, status: :created
    else
      status_code = user.errors.added?(:email, :taken) ? :conflict : :unprocessable_entity
      render json: { errors: user.errors.full_messages }, status: status_code
    end
  end

  private

  def create_new_user(params)
    User.new(
      name: params[:name],
      email: params[:email],
      password: params[:password],
      password_confirmation: params[:password_confirmation]
    )
  end
end
