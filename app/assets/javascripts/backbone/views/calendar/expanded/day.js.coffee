Gandalf.Views.Calendar.Expanded ||= {}

class Gandalf.Views.Calendar.Expanded.Day extends Backbone.View

  initialize: ->
    @date = @options.date
    @hourHeight = Gandalf.hourHeight
    @render()

  tagName: "td"
  className: "cal-day"
  template: JST["backbone/templates/calendar/expanded/day"]

  addEvents: () ->
    if @model     # If there are events
      container = @$(".cal-events:first")
      for e in @model
        if not e.get("multiday")
          view = new Gandalf.Views.Calendar.Expanded.Event(
            model: e
            dayNum: @options.dayNum
            eventCollection: @options.eventCollection
          ) 
          $(container).append(view.el)

  render: () ->
    @$el.html(@template(date: @date)) # Add the calendar day
    if @date.date()  is moment().date()  and 
       @date.month() is moment().month() and 
       @date.year()  is moment().year()
      @$(".cal-day-inner")
        .addClass("today")
        .append("<div id='time-marker'><img id='time-marker-img' src='/assets/y_logo_200.png' /></div>")
      @nowMarker()
      t = this
      setInterval( ->
        t.nowMarker()
      , 15*60*1000)
    @addEvents()
    return this

  # Event handlers

  showMultiday: ->


  # Helpers

  nowMarker: ->
    top = @getNowPosition()
    @$el.find("#time-marker").css(top: "#{top}px")

  getNowPosition: ->
    t = moment()
    hours = t.hours() + t.minutes()/60
    return Math.floor(hours*@hourHeight)
