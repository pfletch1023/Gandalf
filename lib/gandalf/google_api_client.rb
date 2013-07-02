module Gandalf::GoogleApiClient
  
  require 'google/api_client'
  
  SCOPES = {
    DIRECTORY: "https://www.googleapis.com/auth/admin.directory.group",
    CALENDAR: "https://www.googleapis.com/auth/calendar",
    GROUP_SETTINGS: "https://www.googleapis.com/auth/apps.groups.settings"
  }
  
  def self.build_client(scope)

    # Initialize client, load PKCS12 key, and authorize it. 
    key = Google::APIClient::PKCS12.load_key(ENV['SERVICE_ACCOUNT_PKCS12_FILE_PATH'], ENV['KEY_SECRET'])
    asserter = Google::APIClient::JWTAsserter.new(ENV['SERVICE_ACCOUNT_EMAIL'], scope, key)
    client = Google::APIClient.new(application_name: 'TEDxYaleGo')
    client.authorization = asserter.authorize(ENV['ACCOUNT_EMAIL'])
    client
    
  end
  
  def self.setup_client(api, version)
    @client = build_client(SCOPES.values.join(" ")) unless @client
    @client.discovered_api(api, version)
  end
  
  # Google API Group Class Methods
  
  # List google groups
  def self.list_google_groups
        
    directory = setup_client("admin", "directory_v1")
    
    @client.execute({
      api_method: directory.groups.list,
      parameters: { "customer" => ENV["ACCOUNT_EMAIL"] }
    })
  end
  
  # Get google group
  # group_key can be the group's email address, 
  # alias or unique string id
  def self.get_google_group(group_key)
    
    directory = setup_client("admin", "directory_v1")
    
    @client.execute({
      api_method: directory.groups.get,
      parameters: { "groupKey" => group_key }
    })
  end
  
  # Create a google group using body_object
  def self.insert_google_group(body_object)
        
    directory = setup_client("admin", "directory_v1")
    
    @client.execute({
      api_method: directory.groups.insert,
      body_object: body_object
    })
  end
  
  # Update a google group using the passed in group_object
  def self.update_google_group(group_key, group_object)
        
    directory = setup_client("admin", "directory_v1")
    
    @client.execute({
      api_method: directory.groups.update,
      parameters: { "groupKey" => group_key },
      body_object: group_object
    })
  end
  
  # Delete a google group
  # group_key can be the group's email address, 
  # alias or unique string id
  def self.delete_google_group(group_key)
        
    directory = setup_client("admin", "directory_v1")
    
    @client.execute({
      api_method: directory.groups.delete,
      parameters: { "groupKey" => group_key }
    })
  end
  
  # Google API Calendar Class Methods
  
  # List google calendars
  def self.list_google_calendars
        
    calendar = setup_client("calendar", "v3")
    
    @client.execute({
      api_method: calendar.calendar_list.list
    })
  end
  
  def self.get_google_calendar(calendar_id)
        
    calendar = setup_client("calendar", "v3")
    
    @client.execute({
      api_method: calendar.calendar_list.get,
      parameters: { "calendarId" => calendar_id }
    })
  end
  
  def self.insert_google_calendar(calendar_object)
        
    calendar = setup_client("calendar", "v3")
    
    @client.execute({
      api_method: calendar.calendars.insert,
      body_object: calendar_object
    })
  end
  
  def self.delete_google_calendar(calendar_id)
        
    calendar = setup_client("calendar", "v3")
    
    @client.execute({
      api_method: calendar.calendar_list.delete,
      parameters: { "calendarId" => calendar_id }
    })
  end
  
  # Google API Event Class Methods
  
  def self.insert_google_event(calendar_id, event_object)
        
    calendar = setup_client("calendar", "v3")
    
    @client.execute({
      api_method: calendar.events.insert,
      parameters: { "calendarId" => calendar_id },
      body_object: event_object
    })
  end

  def self.get_google_event(calendar_id, event_id)
        
    calendar = setup_client("calendar", "v3")
    
    @client.execute({
      api_method: calendar.events.get,
      parameters: {
        "calendarId" => calendar_id,
        "eventId" => event_id
      }
    })
  end
  
  # Google API ACL Class Methods
  
  def self.insert_google_acl(calendar_id, acl_object)
    
    calendar = setup_client("calendar", "v3")
    
    @client.execute({
      api_method: calendar.acl.insert,
      parameters: { "calendarId" => calendar_id },
      body_object: acl_object
    })
  end
  
  # Google API Member Class Methods
  
  def self.insert_google_member(group_key, member_object)
    
    directory = setup_client("admin", "directory_v1")
    
    @client.execute({
      api_method: directory.members.insert,
      parameters: { "groupKey" => group_key },
      body_object: member_object
    })
  end
  
  # Google API Group Settings Class Methods
  
  def self.get_google_group_settings(group_key)
    
    group_settings = setup_client("groupssettings", "v1")
    
    @client.execute({
      api_method: group_settings.groups.get,
      parameters: { "groupUniqueId" => group_key }
    })
  end
  
end
