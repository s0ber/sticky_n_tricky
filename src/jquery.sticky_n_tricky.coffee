###
  Sticky & tricky for jQuery ~ v1.0.0 ~ https://github.com/kossnocorp/sticky_n_tricky

  This is independent fork of Sticky plugin for jQuery originaly
  written by Anthony Garand.
###

do ($ = jQuery) ->

  DEFAULTS =
    topSpacing:       0
    bottomSpacing:    0
    className:        'is-sticky'
    wrapperClassName: 'sticky-wrapper'
    center:           false
    getWidthFrom:     ''

  $window = $(window)
  $document = $(document)
  sticked = []
  windowHeight = $window.height()

  class StickyView extends Backbone.View

    initialize: ->

    scroll: ->
      scrollTop = $window.scrollTop()
      documentHeight = $document.height()
      dwh = documentHeight - windowHeight
      extra = (if (scrollTop > dwh) then dwh - scrollTop else 0)
      i = 0

      while i < sticked.length
        s = sticked[i]
        elementTop = s.stickyWrapper.offset().top
        etse = elementTop - s.topSpacing - extra
        if scrollTop <= etse
          if s.currentTop isnt null
            s.stickyElement.css("position", "").css "top", ""
            s.stickyElement.parent().removeClass s.className
            s.currentTop = null
        else
          newTop = documentHeight - s.stickyElement.outerHeight() - s.topSpacing - s.bottomSpacing - scrollTop - extra
          if newTop < 0
            newTop = newTop + s.topSpacing
          else
            newTop = s.topSpacing
          unless s.currentTop is newTop
            s.stickyElement.css("position", "fixed").css "top", newTop
            s.stickyElement.css "width", $(s.getWidthFrom).width()  if typeof s.getWidthFrom isnt "undefined"
            s.stickyElement.parent().addClass s.className
            s.currentTop = newTop
        i++

    resize: ->
      windowHeight = $window.height()

    $window: -> @$el

    $document: ->
      @$_document ||= $(document)

  stickyView = new StickyView(el: window)

  methods =
    init: (options) ->
      o = $.extend(DEFAULTS, options)
      @each ->
        stickyElement = $(this)
        stickyId = stickyElement.attr("id")
        wrapper = $("<div></div>").attr("id", stickyId + "-sticky-wrapper").addClass(o.wrapperClassName)
        stickyElement.wrapAll wrapper
        if o.center
          stickyElement.parent().css
            width: stickyElement.outerWidth()
            marginLeft: "auto"
            marginRight: "auto"

        stickyElement.css(float: "none").parent().css float: "right"  if stickyElement.css("float") is "right"
        stickyWrapper = stickyElement.parent()
        stickyWrapper.css height: stickyElement.outerHeight()
        stickyElement.css width: stickyElement.width()
        sticked.push
          topSpacing: o.topSpacing
          bottomSpacing: o.bottomSpacing
          stickyElement: stickyElement
          currentTop: null
          stickyWrapper: stickyWrapper
          className: o.className
          getWidthFrom: o.getWidthFrom

    update: stickyView.scroll

  $window
    .scroll(stickyView.scroll)
    .resize(stickyView.resize)

  $.fn.sticky = (method, args...) ->
    if methods[method]
      methods[method].apply(@, args)
    else if typeof method is "object" or not method
      methods.init.apply(@, arguments)
    else
      $.error "Method " + method + " does not exist on jQuery.sticky"

  $ ->
    setTimeout(stickyView.scroll, 0)
