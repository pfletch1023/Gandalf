Gandalf.Views.Events ||= {}

class Gandalf.Views.Events.CalendarWeekEvent extends Backbone.View

  initialize: ()->
    @color = "rgba(#{@model.get("color")},1)"
    @lightColor = "rgba(#{@model.get("color")},0.7)"
    @eventId = @model.get("eventId")
    @dayNum = @options.dayNum
    ### 
    placement = "left"
    placement = "right" if moment(@model.get("start_at")).day() < 3
    @$el.popover(
      placement: placement
      html: true
      trigger: 'click'
      content: @popoverTemplate(e: @model, color: @lightColor)
    )
    ### 
    @css = {}
    @css.backgroundColor = @color
    @css.lightBackgroundColor = @lightColor
    @css.zIndex = @$el.css("zIndex")
    Gandalf.dispatcher.on("feedEvent:mouseenter", @mouseenter, this)
    Gandalf.dispatcher.on("feedEvent:mouseleave", @mouseleave, this)
    Gandalf.dispatcher.on("feedEvent:click", @feedClick, this)

    @render()

  template: JST["backbone/templates/calendar/calendar_week_event"]

  # This element is an li so that :nth-of-type works properly in the CSS
  tagName: "div"
  className: "js-event cal-event cal-week-event"
  attributes: 
    rel: "event-popover"
  hourHeight: 45
  popoverChild: ".event-name:first"

  events:
    "click": "onClick"
    "mouseenter" : "mouseenter"
    "mouseleave" : "mouseleave"

  getPosition: (time) ->
    t = moment(time)
    hours = t.hours() + t.minutes()/60
    return Math.floor(hours*@hourHeight)

  render: () ->
    e = @model
    @top = @getPosition e.get("calStart")
    @height = @getPosition(e.get("calEnd")) - @top
    style_string = "top: #{@top}px; height: #{@height}px;\
background-color: #{@lightColor}; border: 1pt solid #{@color};"
    $(@el).attr(
      style: style_string
      "data-event-id": @eventId
      "data-organization-id" : e.get("organization_id")
      "data-category-ids" : e.makeCatIdString()
    ).html(@template( event: e ))
    @$el.addClass("day-#{@dayNum}")
    return this

  onClick: () ->
    Gandalf.dispatcher.trigger("event:click", 
      { model: @model, color: @lightColor })
    # @scroll()
    # @popover()

  scroll:() ->
    tHeight = 300 # popover height
    maxHeight = 500
    padTop = 25   # space above popover when scrolling to
    container = @$el.parents(".cal-body")
    if @height > maxHeight
      console.log @height - maxHeight
      scrolltop = @top + (@height - maxHeight) - padTop
    else if @height > tHeight
      scrolltop = @top - padTop
    else
      scrolltop = @top + (@height-tHeight) / 2 - padTop
    $(container).animate scrollTop: (scrolltop), 300

  feedClick: (id) ->
    if @eventId is id
      @$el.click()

  mouseenter: (id) ->
    return if typeof id is "number" and @eventId isnt id
    # Store current CSS values
    @css.width = @$el.css("width")
    # @css.pLeft = @$el.css("paddingLeft")
    @css.left = @$el.css("left")
    @css.zIndex = @$el.css("zIndex")
    @$el.css(
      width: "97%"
      padding: 0
      left: 0
      zIndex: 19
      backgroundColor: @color
      border: "1pt solid #333"
    )
  mouseleave: (id)->
    return if typeof id is "number" and @eventId isnt id
    @$el.css(
      width: @css.width
      # paddingLeft: @css.pLeft
      left: @css.left
      zIndex: @css.zIndex
      backgroundColor: @lightColor
      border: "1pt solid #{@color}"
    )