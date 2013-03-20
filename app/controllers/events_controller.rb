class EventsController < ApplicationController

  before_filter :require_login

  def require_login
    unless logged_in?
      redirect_to '/welcome' # halts request cycle
    end
  end

  def logged_in?
    !!current_user
  end

  def root
  end

  def index
    events = Event.includes(:categories, :organization, :location)
    render json: events
  end

  def show
    event = Event.find(params[:id])
    render json: event
  end

  def create
    name = params[:event][:location]
    location = Location.where(:name => name).first
    location = Location.create(:name => name, :gmaps => true) unless location

    params[:event][:location] = nil
    @event = Event.new(params[:event])
    @event.location = location
    # I know we do this for some particular reason but I forgot why...
    @event.start_at = params[:event][:start_at]
    @event.end_at = params[:event][:end_at]
    @event.set_categories params[:event][:category_ids]
    if @event.save
      render json: @event
    else
      render json: @event.errors, status: :unprocessable_entity
    end
  end

  def update
    location_name = params[:event][:location]
    location = Location.where(:name => location_name).first
    location = Location.create(:name => location_name, :gmaps => true) unless location
    # Set the location id for update_attributes
    params[:event][:location_id] = location.id

    @event = Event.find(params[:event][:id])
    @event.set_categories params[:event][:category_ids]
    if @event.update_attributes(params[:event].except(:location, :category_ids))
      render json: @event
    else
      render json: @event.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @event = Event.find(params[:id])
    if @event.destroy
      render json: @event
    else
      render json: @event.errors, status: :unprocessable_entity
    end
  end

  def search
    query = params[:query]
    events = Event.fulltext_search(query)
    render json: events
  end

end
