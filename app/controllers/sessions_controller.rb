class SessionsController < ApplicationController
  skip_before_action :require_login, only: %i[new create]

  def new
  end

  def create
    user = User.find_by(email: params[:email].to_s.downcase)
    if user&.authenticate(params[:password])
      session[:user_id] = user.id
      redirect_to root_path, notice: "ログインしました"
    else
      flash.now[:alert] = "メールアドレスまたはパスワードが違います"
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    reset_session
    redirect_to new_session_path, notice: "ログアウトしました"
  end
end
