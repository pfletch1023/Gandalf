Gandalf.Views.Events ||= {}

class Gandalf.Views.Events.Index extends Backbone.View

  # options has keys [collection, startDate, period]
  initialize: ()->
    _.bindAll(this, 
      "adjustOverlappingEvents",
      "makeCSSAdjustments",
      "orgVisChange", 
      "catVisChange",
      "renderSubscribedOrganizations",
      "renderSubscribedCategories"
    )

    # Class variables
    @startDate = @options.startDate
    @period = @options.period
    @maxOverlaps = 4                  # Maximum allowed event overlaps
    @first = true                     # First time rendering
    @collection.splitMultiDay()       # Adjust multi-day events
    @render()

    # Render AJAX info
    Gandalf.currentUser.fetchSubscribedOrganizations().then @renderSubscribedOrganizations
    Gandalf.currentUser.fetchSubscribedCategories().then @renderSubscribedCategories

    # Listening for global events
    Gandalf.dispatcher.bind("eventVisibility:change", @hideHidden, this)
    Gandalf.dispatcher.bind("window:resize", @resetEventPositions, this)

  template: JST["backbone/templates/events/index"]
  multidayTemplate: JST["backbone/templates/calendar/calendar_week_multiday"]

  el: "#content"

  events:
    "scroll" : "scrolling"

  # Rendering functions

  renderWeekCalendar: () ->
    view = new Gandalf.Views.Events.CalendarWeek(
      startDate: moment(@startDate)
      days: @days
    )
    @$("#calendar-container").append(view.el)
    if @first
      @$(".cal-body").animate scrollTop: 550, 300
      @first = false
    @hideHidden()

  renderMonthCalendar: () ->
    view = new Gandalf.Views.Events.CalendarMonth(
      startDate: moment(@startDate)
      days: @days
    )
    @$("#calendar-container").append(view.el)
    @hideHidden()

  renderWeekMultiday: () ->
    evs = @collection.getMultidayEvents()
    for event in evs
      html = @multidayTemplate({ e: event })
      $(".cal-multiday").append(html)
      console.log "multiday", $(".cal-multiday")

  renderFeed: () ->
    @$("#feed-list").append("<p>You have no upcoming events</p>") if _.isEmpty(@days)
    @doneEvents = []
    for day, events of @days
      @addFeedDay(day, events)

  addFeedDay: (day, events) ->
    view = new Gandalf.Views.Events.FeedDay(day: day, collection: events,done: @doneEvents)
    @$("#feed-list").append(view.el)

  renderSubscribedOrganizations: ->
    subscriptions = Gandalf.currentUser.get('subscribed_organizations')
    hidden = @collection.getHiddenOrgs()
    for s in subscriptions
      invisible = false
      invisible = true if s.id in hidden
      view = new Gandalf.Views.Organizations.Short(model: s, invisible: invisible)
      $("#subscribed-organizations-list").append(view.el)
  
  renderSubscribedCategories: ->
    subscriptions = Gandalf.currentUser.get('subscribed_categories')
    hidden = @collection.getHiddenCats()
    for s in subscriptions
      invisible = false
      invisible = true if s.id in hidden
      view = new Gandalf.Views.Categories.Short(model: s, invisible: invisible)
      $("#subscribed-categories-list").append(view.el)

  renderCalendar: () ->
    if @period == "month"
      @renderMonthCalendar()
    else 
      @renderWeekCalendar()
      @renderWeekMultiday()
      @adjustOverlappingEvents()

  render: () ->
    $(@el).html(@template({ user: Gandalf.currentUser }))
    @days = @collection.sortAndGroup()
    @renderFeed()
    @renderCalendar()
    t = this
    setInterval( ->
      t.resetEventPositions()
    , 20000)
    return this
  
  # Event handlers

  hideHidden: () ->
    # $(".cal-week-event").effect("puff")
    orgs = @collection.getHiddenOrgs()
    cats = @collection.getHiddenCats()
    @orgVisChange(orgs)
    @catVisChange(cats)

  scrolling: () ->
    if("#feed-list").scrollTop() + $(".feed").height() == $("#feed-list").height()
      console.log 'go!'

  resetEventPositions: () ->
    $(".cal-week-event").css({ width: "96%" }) # For window resizing
    @makeCSSAdjustments()

  # Helpers

  orgVisChange: (hiddenOrgs) ->
    $(".js-event").removeClass("event-hidden-org")
    for orgId in hiddenOrgs
      $(".js-event[data-organization-id='#{orgId}']").addClass "event-hidden-org"
    @adjustOverlappingEvents()

  catVisChange: (hiddenCats) ->
    $(".js-event").removeClass("event-hidden-cat")
    for catId in hiddenCats
      id = catId+","
      $(".js-event[data-category-ids*='#{id}']").addClass "event-hidden-cat"
    @adjustOverlappingEvents()

  adjustOverlappingEvents: () ->
    # If an event overlaps with one other, they both get class 'overlap-2', etc. for 3, 4
    # TO DO: if there are more than @maxOverlaps overlaps, create an alert
    # that says not all the events are being shown
    overlaps = @collection.findOverlaps()
    $(".cal-week-event").removeClass("overlap-2 overlap-3 overlap-4 hide")
    for myId, ids of overlaps
      num = ids.length + 1
      $(".cal-week-event[data-event-id='#{myId}']").addClass "overlap-#{num}"
      count = 0
      for id in ids
        if count < @maxOverlaps
          $(".cal-week-event[data-event-id='#{id}']").addClass "overlap-#{num}"
        else
          $(".cal-week-event[data-event-id='#{id}']").addClass "hide"
        count++

    @makeCSSAdjustments()

  # CSS wasn't strong enough for the kind of styling I wanted to do...
  # so we're doing it in JS
  makeCSSAdjustments: () ->
    overlapIndex = 2  # Because we start caring when 2 or more things overlap
    calZ = 10
    all = $(".cal-events")
    for a in all
      console.log a
      while overlapIndex <= @maxOverlaps
        width = Math.floor(98/overlapIndex)
        selector = ".cal-week-event.overlap-#{overlapIndex}"
        selector += ":not(.event-hidden-org, .event-hidden-cat)"
        evs = $(a).find(selector)
        $(evs).css({ width: "#{width}%"})
        _.each evs, (e, index) ->
          num = index%overlapIndex
          console.log "#{width*num}"
          $(e).css(
            left: "#{width*num}%"
            zIndex: calZ - num
          )

        overlapIndex++
        ### 
        if index%overlapIndex is 0
          $(e).css(
            left: 0
          )
        else if index%overlapIndex is 1
          $(e).css(
            left: "#{width}%"
            zIndex: calZ - 1
          )
        else if index%overlapIndex is 2
          $(e).css(
            left: "#{width*2}%"
            zIndex: calZ - 2
          )
        else if index%overlapIndex is 3
          $(e).css(
            left: "#{width*3}%"
            zIndex: calZ - 3
          )
        ###
        