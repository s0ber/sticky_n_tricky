###
  Sticky & tricky for jQuery ~ v1.0.0 ~ https://github.com/kossnocorp/sticky_n_tricky

  This is independent fork of Sticky plugin for jQuery originaly
  written by Anthony Garand.
###

@StickyAndTricky = {}

DEFAULT_OPTIONS =
  padding: 0
  to:      'top'

class StickyAndTricky.StickyView extends Backbone.View

  enabled: false

  initialize: ->
    Object.merge(@options, DEFAULT_OPTIONS, false, false)
    @setup()

  # Setup sticky
  setup: ->
    return unless @isCanBeSticky()

    @enabled = true

    @stickyWindow().add(@)

    @wrapEl()
    @copyStylesToWrapper()
    @fixWidth()

    @stickyWindow().recalculate([@])

  # Restore
  restore: ->
    @enabled = false

    @clearPosition()
    @unwrapEl()
    @restoreWidth()

  # Check is window height is enough to stick el
  isCanBeSticky: ->
    @stickyWindow().haveEnoughSpace @$el.height()

  # Check is element should be enabled
  applyNewWindowSize: ->
    if @enabled
      if @isCanBeSticky()
        @$el.css(left: @wrapper().offset().left)
      else
        @restore()
    else
      @setup()

  # Calculate view position
  calculatePosition: (args...) ->
    return unless @enabled

    if @isFixed(args...)
      @setPosition if @options.to == 'top'
        @newTop(args...)
      else
        @newBottom(args...)
    else
      @clearPosition()

  # Set new position
  setPosition: (position) ->
    return if @currentPosition is position

    @$el
      .css(position: 'fixed')
      .css(@options.to, position)
    @currentPosition = position

  # Reset position to original
  clearPosition: ->
    return unless @currentPosition?
    @$el
      .css(position: '')
      .css(@options.to, '')

    @currentPosition = null

  # Returns new top position
  newTop: (documentHeight, scrollTop, scrollBottom, extraGap) ->
    top = documentHeight - @$el.outerHeight() - @options.padding - scrollTop - extraGap

    # Hack for OSX "overscroll"
    if top < 0
      top + @options.padding
    else
      @options.padding

  # Returns new bottom position
  newBottom: (documentHeight, scrollTop, scrollBottom, extraGap) ->
    @options.padding

  # Is el position should be fixed
  isFixed: (documentHeight, scrollTop, scrollBottom, extraGap) ->
    if @options.to == 'top'
      # TODO: WTF is etse?!
      etse = @top() - @options.padding - extraGap
      scrollTop > etse
    else
      scrollBottom < @bottom()

  # Wrap el with div
  wrapEl: ->
    @$el.wrapAll('<div></div>')

  # Unwrap el
  unwrapEl: ->
    @$el.unwrap()
    @$_wrapper = null

  # Returns absolute element top
  top: ->
    @wrapper().offset().top

  # Returns bottom offset
  bottom: ->
    @wrapper().offset().top + @wrapper().outerHeight()

  # Fix el width
  fixWidth: ->
    @$el.css(width: @$el.width())

  # Restore el width
  restoreWidth: ->
    @$el.css(width: '')

  # Copy css to wrapper
  copyStylesToWrapper: ->
    if @$el.css('float') is 'right'
      @$el.css(float: 'none')
      @wrapper().css(float: 'right')

    @wrapper().css(height: @$el.outerHeight())

  # Returns sticky wrapper
  wrapper: ->
    @$_wrapper ||= @$el.parent()

  # Return current instance of StickyWindowView
  stickyWindow: ->
    StickyAndTricky.StickyWindowView.current

# Sticky window view class
class StickyAndTricky.StickyWindowView extends Backbone.View

  events:
    scroll: 'scroll'
    resize: 'resize'

  initialize: ->
    @views = []
    StickyAndTricky.StickyWindowView.current = @

  # Add view to recalculate list
  add: (view) ->
    @views.push view

  # Remove view from recalculate list
  remove: (view) ->
    @views.remove view

  # Window scroll callback
  scroll: ->
    @recalculate()

  # Recalculate all view positions
  recalculate: (views) ->
    return if (views || @views).isEmpty()

    scrollTop      = @scrollTop()
    scrollBottom   = scrollTop + @height()
    documentHeight = @$document().height()
    overflowHeight = documentHeight - @height()

    if scrollTop > overflowHeight
       extraGap = overflowHeight - scrollTop

    for view in views || @views
      view.calculatePosition(documentHeight, scrollTop, scrollBottom, extraGap || 0)

  # Clear height cache and pass height to recalculate list
  resize: ->
    @_height = undefined

    for view in @views
      view.applyNewWindowSize()

  # Check is height is enough for passed size
  haveEnoughSpace: (height) ->
    @height() >= height

  # Returns and cache height
  height: ->
    @_height ||= @$el.height()

  # Return current scroll top
  scrollTop: ->
    @$el.scrollTop()

  # Document jQuery object
  $document: ->
    @$_document ||= $(document)

# Create sticky window view
new StickyAndTricky.StickyWindowView(el: window)
