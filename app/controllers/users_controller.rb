class UsersController < ApplicationController
  
  before_filter :require_login

  def require_login
    unless logged_in?
      redirect_to '/welcome' # halts request cycle
    end
  end
 
  def logged_in?
    !!current_user
  end
  
  def me
    render json: current_user
  end
  
end