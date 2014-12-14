$.fn.snappish = (opts) ->
  settings = $.extend {}, $.fn.snappish.defaults, opts

  # Elements
  $wrapper = $(this)
  $main = $(settings.mainSelector)
  $slides = $(settings.slidesSelector)


  # Variables
  numberOfSlides = $slides.length
  currentSlideNum = 0
  scrollDistancePerSlide = 100/numberOfSlides
  inTransition = false
  transitionDuration = $main.css('transition-duration').toString()

  if transitionDuration.match(/s$/)
    transitionDuration = transitionDuration.replace(/s$/, '') * 1000
  else
    transitionDuration = transitionDuration.replace(/ms$/, '') * 1


  # Styling
  $wrapper.addClass 'snappish-wrapper'
  $main.addClass 'snappish-main'
  $main.addClass "snappish-#{numberOfSlides}-slides"
  $slides.addClass 'snappish-slide'


  # Scrolling
  scroll = (direction) ->
    targetSlideNum = null

    if direction == 'down' && currentSlideNum < numberOfSlides-1
      targetSlideNum = currentSlideNum+1
    else if direction == 'up' && currentSlideNum > 0
      targetSlideNum = currentSlideNum-1

    scrollToSlide(targetSlideNum) if targetSlideNum?

  scrollToSlide = (targetSlideNum, doAnimate) ->
    return if targetSlideNum == currentSlideNum
    doAnimate =  (typeof doAnimate == "undefined" || doAnimate);

    inTransition = true
    targetScrollDistance = targetSlideNum * scrollDistancePerSlide * -1

    eventData =
      fromSlideNum: currentSlideNum
      fromSlide: $slides.eq(currentSlideNum)
      toSlideNum: targetSlideNum
      toSlide: $slides.eq(targetSlideNum)
      wrapper: $wrapper
      main: $main
      transitionDuration: transitionDuration

    $wrapper.trigger 'scrollbegin.snappish', eventData
    if !doAnimate
      originalTransitionDuration = $main.css('transition-duration').toString()
      $main.css 'transition-duration', '0'
    $main.css 'transform', "translate3d(0,#{targetScrollDistance}%,0)"
    currentSlideNum = targetSlideNum

    triggerScrollEnd = (eventData) ->
      $wrapper.trigger 'scrollend.snappish', eventData

    if doAnimate
      setTimeout ->
        triggerScrollEnd(eventData)
      , transitionDuration

      setTimeout ->
        inTransition = false
      , transitionDuration + 300
    else
      triggerScrollEnd(eventData)
      inTransition = false
      setTimeout ->
        $main.css('transition-duration', originalTransitionDuration)
      , 0

  # Mousewheel handling
  if settings.mousewheelEnabled
    $wrapper.on 'mousewheel', (e, delta, deltaX, deltaY) ->
      return if inTransition

      if deltaY < 0
        scroll('down')
      else if deltaY > 0
        scroll('up')


  # Swipe handling
  if settings.swipeEnabled
    $.event.special.swipe.settings.threshold = settings.swipeThreshold

    $wrapper.on 'swipeup', (e) ->
      scroll('down')

    $wrapper.on 'swipedown', (e) ->
      scroll('up')


  # External events handling
  $wrapper.on 'scrollup.snappish', (e) ->
    targetSlideNum = currentSlideNum-1
    scrollToSlide(targetSlideNum) if targetSlideNum >= 0

  $wrapper.on 'scrolldown.snappish', (e) ->
    targetSlideNum = currentSlideNum+1
    scrollToSlide(targetSlideNum) if targetSlideNum < numberOfSlides

  $wrapper.on 'scrollto.snappish', (e, opts) ->
    doAnimate = true
    if typeof opts != 'undefined'
      if typeof opts == 'object'
        targetSlideNum = opts.targetSlideNum
        if typeof opts.doAnimate != 'undefined'
          doAnimate = opts.doAnimate
      else if typeof opts  == 'number' || typeof opts == 'string'
        targetSlideNum = opts
      else
        return
    scrollToSlide(targetSlideNum, doAnimate)


  return $wrapper


# Default configuration
$.fn.snappish.defaults =
  mainSelector: '.snappish-main'
  slidesSelector: '.snappish-main > *'
  mousewheelEnabled: true
  swipeEnabled: true
  swipeThreshold: 0.1
