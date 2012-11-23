Gandalf.Views.Events ||= {}

class Gandalf.Views.Events.CalendarEvent extends Backbone.View

  initialize: ()->
    _.bindAll(@)
    @render()
    @$el.popover(
      placement: 'left'
      html: true
      trigger: 'click'
      content: @popoverTemplate(e: @model)
    )
    @css = {}
    @css.backgroundColor = @$el.css("backgroundColor")
    @css.zIndex = @$el.css("zIndex")
    Gandalf.dispatcher.on("feedEvent:mouseenter", @mouseenter)
    Gandalf.dispatcher.on("feedEvent:mouseleave", @mouseleave)


  template: JST["backbone/templates/events/calendar_event"]
  popoverTemplate: JST["backbone/templates/events/calendar_popover"]

  # This element is an li so that :nth-of-type works properly in the CSS
  tagName: "li"
  className: "cal-event"
  attributes: 
    rel: "event-popover"
  hourHeight: 45
  popoverChild: ".event-name:first"

  events:
    "click": "onClick"

  getPosition: (time) ->
    t = moment(time)
    hours = t.hours() + t.minutes()/60
    return Math.floor(hours*@hourHeight)

  render: () ->
    e = @model
    top = @getPosition e.get("start_at")
    height = @getPosition(e.get("end_at")) - top
    style_string = "top: "+top+"px; height: "+height+"px;"
    $(@el).attr({ style: style_string, "data-id": e.get("id") }).html(@template(
      event: e
      top: top
      height: height
    ))
    return this

  onClick: () ->
    # Demo code to show how one may hide and show events
    # $(".cal-event").css("opacity", 1)
    # @$el.css("opacity", 0.2)
    # Gandalf.dispatcher.trigger("event:changeVisible", @model.get("id"))
    @popover()

  popover: () ->
    id = @model.get("id")
    # Hide all other popovers
    otherPopovers = $("[rel='event-popover']:not([data-id='"+id+"'])")
    otherPopovers.popover('hide') if otherPopovers
    # Add event handler to close button
    t = this
    $(".popover .close").click (e) ->
      t.$el.popover('hide')

  mouseenter: (id) ->
    console.log @css
    if !id || @model.get("id") == id
      @$el.css(
        backgroundColor: "rgba(170,170,170,0.9)"
        zIndex: 15
      )

  mouseleave: (id) ->
    if !id || @model.get("id") == id
      @$el.css(
        backgroundColor: @css.backgroundColor
        zIndex: @css.zIndex
      )
