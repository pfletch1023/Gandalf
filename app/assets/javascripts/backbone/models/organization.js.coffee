class Gandalf.Models.Organization extends Backbone.Model
  paramRoot: 'organization'

  defaults:
    name: null
  
  fetchEvents: ->
    $.ajax
      type: 'GET'
      dataType: 'json'
      url: '/organizations/' + @id + '/events'
      success: (data) =>
        @set events: data
  
  fetchSubscribedUsers: ->
    $.ajax
      type: 'GET'
      dataType: 'json'
      url: '/organizations/' + @id + '/subscribed_users'
      success: (data) =>
        @set users: data
        
  asJSON: =>
    organization = _.clone this.attributes
    return _.extend organization, {image: this.get('image')}
    
class Gandalf.Collections.Organizations extends Backbone.Collection
  model: Gandalf.Models.Organization
  url: '/organizations'
