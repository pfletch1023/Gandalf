Gandalf.Views.Organizations ||= {}

class Gandalf.Views.Organizations.Show extends Backbone.View
  
  template: JST["backbone/templates/organizations/show"]
  
  el: '#content'
  
  initialize: ->
    @string = @options.string
    @render()
  
  renderFollowing: =>
    if Gandalf.currentUser.get('subscribed_organizations')
      if Gandalf.currentUser.isFollowing(@model, 'subscribed_organizations')
        $("button.follow").addClass 'following'
      else
        $("button.follow").attr 'class','follow'
    else
      Gandalf.currentUser.fetchSubscribedOrganizations().then @renderFollowing
  
  renderCategories: ->
    categories = @model.get('categories')
    cats = []
    if categories
      for category in categories
        cats.push "<a href='#categories/#{category.id}'>#{category.name}</a>"
      @$('.organization-categories').append( cats.join(', ') )
  
  renderEvents: =>
    events = @model.get("events")
    view = new Gandalf.Views.Calendar.Index(
      type: @options.period
      events: events
      startDate: @options.startDate
    )
    $(".content-calendar").append(view.el)
            
  render: ->
    @$el.html(@template(organization: @model))
    Gandalf.calendarHeight = $(".content-calendar").height()
    calNav = new Gandalf.Views.CalendarNav(
      period: @options.period
      startDate: @options.startDate
      root: "organizations/#{@model.get('id')}"
    )
    @$(".content-cal-nav").html(calNav.el)
    @renderCategories()
    @renderFollowing()
    @model.fetchEvents(@string).then @renderEvents
    return this
  
  events:
    "click .follow" : "follow"
  
  follow: (event) ->
    if $(event.target).hasClass 'following'
      Gandalf.currentUser.unfollow(@model).then @renderFollowing
    else
      Gandalf.currentUser.follow(@model).then @renderFollowing
    