class Group < ActiveRecord::Base
  
  include Gandalf::Utilities
  include Gandalf::GoogleApiClient
  
  # Associations
  has_many :events, foreign_key: "calendar_id"
  belongs_to :groupable, polymorphic: true
  
  # Callbacks
  before_validation :set_slug
  before_create :set_apps_email
  before_create :setup_google_group
  after_create :create_google_calendar
  after_create :create_google_acl
  after_destroy :destroy_google_calendar
  after_destroy :destroy_google_group
  
  # Validations
  validates_presence_of :name, :slug, :groupable_id, :groupable_type
  
  # Methods
  
  # Uses Gandalf::Utilities make_slug method to convert the group name 
  # to a hyphen-separated, lowercase string
  def set_slug
    self.slug = make_slug(name)
  end
  
  # Sets the apps_email attribute according to group naming rule.
  def set_apps_email
    self.apps_email = "yalego.#{self.slug}@tedxyale.com"
  end
  
  # Google API Methods
  
  # Creates a google group and sets the model's apps_id and apps_email.
  def setup_google_group
    
    result = Gandalf::GoogleApiClient.insert_google_group({
      "email" => self.apps_email || self.set_apps_email,
      "name" => self.name,
      "description" => self.description
    })
    
    # Checks if a conflict exists in the database.
    if result.status == 409
      result = Gandalf::GoogleApiClient.get_google_group(self.apps_email)
    end
    
    # Set the apps_id and apps_email from the returned object.
    self.apps_id = result.data.id
    self.apps_email = result.data.email
    
  end
  
  # Deletes the google group.
  def destroy_google_group
    result = Gandalf::GoogleApiClient.delete_google_group(self.apps_id)
    result.data
  end
  
  def get_google_group_settings
    result = Gandalf::GoogleApiClient.get_google_group_settings(self.apps_email)
  end
  
  # Uses the insert_google_calendar class method to create a google calendar.
  def create_google_calendar
    unless self.apps_cal_id
      result = Gandalf::GoogleApiClient.insert_google_calendar({
        "summary" => self.name
      })
    
      self.apps_cal_id = result.data.id
      self.save
    end
  end
  
  # Uses the get_google_calendar class method to fetch the group's google calendar.
  def get_google_calendar
    result = Gandalf::GoogleApiClient.get_google_calendar(self.apps_cal_id)
    result.data
  end
  
  # Deletes the group's associated calendar
  def destroy_google_calendar
    result = Gandalf::GoogleApiClient.delete_google_calendar(self.apps_cal_id)
    result.data
  end
  
  # Creates a Google access control rule with the apps_cal_id
  # of the group and a reader access control object.
  def create_google_acl
    result = Gandalf::GoogleApiClient.insert_google_acl(self.apps_cal_id, {
      "role" => "reader",
      "scope" => {
        "type" => "group",
        "value" => self.apps_email
      }
    })
    result.data
  end
      
end
