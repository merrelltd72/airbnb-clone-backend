class UsersController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :create ]

  # POST /users - Create a new user
  def create
    user = create_new_user(signup_params)
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

  # GET /me - Current user profile data
  def me
    render json: me_payload(current_user), status: :ok
  end

  # PATCH /me - Update current user profile data
  def update_me
    if current_user.update(me_profile_params)
      render json: me_payload(current_user), status: :ok
    else
      render json: { errors: current_user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # PATCH /me/password - Update current user password
  def update_password
    pwd = me_password_params
    unless current_user.authenticate(pwd[:current_password])
      return render json: { error: "Current password is incorrect" }, status: :bad_request
    end

    if current_user.update(
      password: pwd[:new_password],
      password_confirmation: pwd[:new_password_confirmation]
    )
      render json: { message: "Password updated successfully" }, status: :ok
    else
      render json: { errors: current_user.errors.full_messages }, status: :unprocessable_entity
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

  def signup_params
    params.permit(:name, :email, :password, :password_confirmation)
  end

  def me_profile_params
    # Intentionally no role or email updates here to prevent escalation/account takeover paths.
    params.permit(:name, :image)
  end

  def me_password_params
    params.permit(:current_password, :new_password, :new_password_confirmation)
  end

  def me_payload(user)
    {
      id: user.id,
      name: user.name,
      email: user.email,
      role: user.role,
      image: user.image,
      last_login_at: user.last_login_at
    }
  end
end
