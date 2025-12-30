class SessionsController < ApplicationController
  def create
    user = User.find_or_create_from_omniauth(request.env["omniauth.auth"])
    session[:user_id] = user.id
    redirect_to root_path, notice: "Signed in!"
  end

  def destroy
    session.delete(:user_id)
    redirect_to root_path, notice: "Signed out!"
  end

  def failure
    redirect_to root_path, alert: "Authentication failed: #{params[:message]}"
  end
end
