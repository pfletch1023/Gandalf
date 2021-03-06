class AdminController < ApplicationController
  
  before_filter :require_admin
  
  def index
    redirect_to "/admin/organizations"
  end
  
  def users
    @users = User.all
  end
  
  def events
    @events = Event.all
  end
  
  def organizations
    @organizations = Organization.all
  end
  
  def categories
    @categories = Category.all
  end
  
  def locations
    @locations = Location.all
  end
  
  def import_categories
    Category.import_categories(params[:file])
    redirect_to "/admin/categories"
  end
  
  def import_organizations
    Organization.import_student_organizations(params[:file])
    redirect_to "/admin/users"
  end
  
  def scrape
    date = DateTime.now.strftime("%Y%m%d")
    if params[:url]
      url = params[:url]
    elsif params[:period] == "week"
      url = "http://calendar.yale.edu/cal/opa/week/#{date}/All/?showDetails=yes"
    elsif params[:period] == "month"
      url = "http://calendar.yale.edu/cal/opa/month/#{date}/All/?showDetails=yes"
    end
    if url
      Event.scrape_yale_events(url)
    end
    redirect_to "/admin/events"
  end
  
end
