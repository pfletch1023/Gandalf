class OrganizationsController < ApplicationController
  
  def index
    @organizations = Organization.all
    render json: @organizations.to_json(:include => [:categories])
  end
  
  def show
    @organization = Organization.find(params[:id])
    render json: @organization.to_json(:include => [:categories])
  end
  
  def edit
    @organization = Organization.find(params[:id])
    if current_user.has_authorization_to(@organization)
      render json: @organization
    else
      render json: "User does not have access", status: 403
    end
  end
  
  def update
    @organization = Organization.find(params[:id])
    if @organization.update_attributes(params[:organization])
      render json: @organization
    else
      render json: @organization.errors, status: :unprocessable_entity
    end
  end
  
  def add_image
    @organization = Organization.find(params[:id])
    @organization.image = params[:image]
    @organization.save
    render json: @organization
  end
  
  def events
    @organization = Organization.find(params[:id])
    if params[:start_at] && params[:end_at]
      @events = @organization.events_with_period(params[:start_at], params[:end_at])
    else
      @events = @organization.events
        .includes(:location, :organization, :categories)
        .order("start_at")
    end
    render json: @events.as_json
  end
  
  def subscribed_users
    @organization = Organization.find(params[:id])
    @users = @organization.subscribers
    @admins = @organization.admins
    @users = @users - @admins
    render json: @users.as_json
  end
  
  def admins
    @organization = Organization.find(params[:id])
    @admins = @organization.admins
    render json: @admins.as_json
  end
  
  def search
    query = params[:query]
    organizations = Organization.fulltext_search(query)
    render json: organizations.to_json(:include => [:categories])
  end
  
  def subscriber_email
    organization = Organization.find(params[:id])
    user_ids = params[:user_ids]
    body = params[:body]
    subject = params[:subject]
    user_ids.each do |id|
      user = User.find(id)
      UserMailer.subscriber_email(user.email, body, subject).deliver
    end
    render json: organization
  end
  
end
