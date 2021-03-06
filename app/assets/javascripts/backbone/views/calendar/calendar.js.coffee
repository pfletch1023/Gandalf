Gandalf.Views ||= {}

class Gandalf.Views.Calendar extends Backbone.View

  initialize: ->
    # Class variables
    @eventCollection = @options.eventCollection
    @startDate = @options.startDate
    # Listening for global events
    # Gandalf.dispatcher.bind("eventVisibility:change", @hideHidden, this)
    # Gandalf.dispatcher.bind("window:resize", @resetEventPositions, this)
    @render()

  className: "calendar"

  render: ->
    if @options.type is 'month'
      view = new Gandalf.Views.Calendar.Compressed.Index
        startDate: moment(@startDate)
        eventCollection: @eventCollection

      @$el.append view.el
    else
      numDays = 7
      numDays = 1 if @options.type is 'list'
      cal = new Gandalf.Views.Calendar.Expanded.Index
        startDate: moment(@startDate)
        eventCollection: @eventCollection
        numDays: numDays

      @$el.append cal.el

      @adjustOverlappingEvents()
      # Due to rendering bugs, we rerender the view every 20 seconds.
      # Ugly hack, I know...but #whateva.
      t = this
      setInterval( ->
        t.resetEventPositions()
      , 20000)
      # @hideHidden()
    return this

  # Event handlers

  # hideHidden: () ->
  #   orgs = @eventCollection.getHiddenOrgs()
  #   cats = @eventCollection.getHiddenCats()
  #   @orgVisChange(orgs)
  #   @catVisChange(cats)

  resetEventPositions: () ->
    @$el.find(".cal-week-event").css({ width: "96%" }) # For window resizing
    @makeCSSAdjustments()

  # Helpers

  adjustOverlappingEvents: () ->
    @maxOverlaps = 2
    # If an event overlaps with one other, they both get class 'overlap-2', etc. for 3, 4
    overlaps = @eventCollection.findOverlaps()
    @$el.find(".cal-week-event").removeClass("overlap-2 overlap-3 overlap-4 hide")
    for myId, ids of overlaps
      num = ids.length + 1
      @maxOverlaps = num if num > @maxOverlaps
      # num = @maxOverlaps if num > @maxOverlaps
      @$el.find(".cal-week-event[data-event-id='#{myId}']").addClass "overlap-#{num}"
      count = 0
      for id in ids
        @$el.find(".cal-week-event[data-event-id='#{id}']").addClass "overlap-#{num}"
        count++
    @makeCSSAdjustments()

  # CSS wasn't strong enough for the kind of styling I wanted to do...
  # so we're doing it in JS
  # Cost: 21 * number of events
  makeCSSAdjustments: () ->
    calZ = 10
    for i in [0...7]
      # overlapIndex is the number of items overlapping
      for overlapIndex in [2..@maxOverlaps]
        width = Math.floor(105/overlapIndex)
        fraction = Math.floor(90/overlapIndex)
        selector = ".cal-week-event.overlap-#{overlapIndex}.day-#{i}"
        selector += ":not(.hide, .event-hidden-org, .event-hidden-cat)"
        evs = @$el.find(selector)
        $(evs).css({ width: "#{width}%"})
        for e, index in evs
          num = index%overlapIndex
          # if index = 0 : left: 0
          # for 2 overlaps:
            # width = 47%
            # left = 50%
          $(e).css(
            left: "#{fraction*num}%"
            # zIndex: calZ - num
          )

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

  
