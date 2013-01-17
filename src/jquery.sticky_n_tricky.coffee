###
  Sticky & tricky for jQuery ~ v1.0.0 ~ https://github.com/kossnocorp/sticky_n_tricky

  This is independent fork of Sticky plugin for jQuery originaly
  written by Anthony Garand.
###

do ($ = jQuery) ->
  defaults =
    topSpacing: 0
    bottomSpacing: 0
    className: "is-sticky"
    wrapperClassName: "sticky-wrapper"
    center: false
    getWidthFrom: ""

  $window = $(window)
  $document = $(document)
  sticked = []
  windowHeight = $window.height()
  scroller = ->
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

  resizer = ->
    windowHeight = $window.height()

  methods =
    init: (options) ->
      o = $.extend(defaults, options)
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



    update: scroller


  # should be more efficient than using $window.scroll(scroller) and $window.resize(resizer):
  if window.addEventListener
    window.addEventListener "scroll", scroller, false
    window.addEventListener "resize", resizer, false
  else if window.attachEvent
    window.attachEvent "onscroll", scroller
    window.attachEvent "onresize", resizer
  $.fn.sticky = (method) ->
    if methods[method]
      methods[method].apply this, Array::slice.call(arguments_, 1)
    else if typeof method is "object" or not method
      methods.init.apply this, arguments_
    else
      $.error "Method " + method + " does not exist on jQuery.sticky"

  $ ->
    setTimeout scroller, 0
