$.fn.snappish = (opts) ->
  settings = $.extend {}, $.fn.snappish.defaults, opts

  # Elements
  $wrapper = $(this)
  $main = $(settings.mainSelector)
  $slides = $(settings.slidesSelector)

  # Variables
  slidesLength = $slides.length
  counter = 1
  scrollDirection = null
  scrollDistance = 100/slidesLength
  inTransition = false

  # Styling
  $wrapper.css
    width: '100%'
    height: '100%'
    float: 'left'
    zIndex: 10
    overflow: 'hidden'

  $main.css
    width: '100%'
    height: "#{slidesLength*100}%"
    zIndex: 9
    'transition': "all #{settings.transitionDuration}ms ease"

  $slides.css
    width: '100%'
    height: "#{scrollDistance}%"
    'transform': 'translateZ(0)'

  # Scrolling
  scrollAnimate = (distance) ->
    inTransition = true
    $main.css 'transform', "translate3d(0,#{distance}%,0)"
    setTimeout ->
      inTransition = false
    , settings.transitionDuration + settings.transitionWaitAfter

  scrollLogic = ->
    if scrollDirection == 'down' && counter < slidesLength
      scrollAnimate counter*-scrollDistance
      counter++
    else if scrollDirection == 'up' && counter > 1
      scrollAnimate (counter-2)*-scrollDistance
      counter--
    else
      inTransition = false

  # Mousewheel handling
  if settings.mousewheelEnabled
    $wrapper.on 'mousewheel', (e, delta, deltaX, deltaY) ->
      return if inTransition

      if deltaY < 0
        scrollDirection = 'down'
      else if deltaY > 0
        scrollDirection = 'up'

      scrollLogic()

  # Swipe handling
  if settings.swipeEnabled
    $.event.special.swipe.settings.threshold = settings.swipeThreshold

    $wrapper.on 'swipeup', (e) ->
      scrollDirection = 'down'
      scrollLogic()

    $wrapper.on 'swipedown', (e) ->
      scrollDirection = 'up'
      scrollLogic()


# Default configuration
$.fn.snappish.defaults =
  mainSelector: '.snappish-main'
  slidesSelector: '.snappish-main > *'
  transitionDuration: 1000
  transitionWaitAfter: 300
  mousewheelEnabled: true
  swipeEnabled: true
  swipeThreshold: 0.1
