# Controller 
class MainController < ApplicationController
  
  before_filter CASClient::Frameworks::Rails::Filter, :only => ["login"]
  #before_filter :require_login, :only => ["root"]
  before_filter :require_admin, :only => ["root"]
  
  def welcome
  end

  def login
    redirect_to "/"
  end

  def root
    @me = current_user
  end
  
  def logout
    CASClient::Frameworks::Rails::Filter.logout(self)
  end
  
  def search_all
  end
  
end
