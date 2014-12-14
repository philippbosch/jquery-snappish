// Generated by CoffeeScript 1.3.3
(function() {

  $.fn.snappish = function(opts) {
    var $main, $slides, $wrapper, currentSlideNum, inTransition, numberOfSlides, scroll, scrollDistancePerSlide, scrollToSlide, settings, transitionDuration;
    settings = $.extend({}, $.fn.snappish.defaults, opts);
    $wrapper = $(this);
    $main = $(settings.mainSelector);
    $slides = $(settings.slidesSelector);
    numberOfSlides = $slides.length;
    currentSlideNum = 0;
    scrollDistancePerSlide = 100 / numberOfSlides;
    inTransition = false;
    transitionDuration = $main.css('transition-duration').toString();
    if (transitionDuration.match(/s$/)) {
      transitionDuration = transitionDuration.replace(/s$/, '') * 1000;
    } else {
      transitionDuration = transitionDuration.replace(/ms$/, '') * 1;
    }
    $wrapper.addClass('snappish-wrapper');
    $main.addClass('snappish-main');
    $main.addClass("snappish-" + numberOfSlides + "-slides");
    $slides.addClass('snappish-slide');
    scroll = function(direction) {
      var targetSlideNum;
      targetSlideNum = null;
      if (direction === 'down' && currentSlideNum < numberOfSlides - 1) {
        targetSlideNum = currentSlideNum + 1;
      } else if (direction === 'up' && currentSlideNum > 0) {
        targetSlideNum = currentSlideNum - 1;
      }
      if (targetSlideNum != null) {
        return scrollToSlide(targetSlideNum);
      }
    };
    scrollToSlide = function(targetSlideNum, doAnimate) {
      var eventData, originalTransitionDuration, targetScrollDistance, triggerScrollEnd;
      if (targetSlideNum === currentSlideNum) {
        return;
      }
      doAnimate = typeof doAnimate === "undefined" || doAnimate;
      inTransition = true;
      targetScrollDistance = targetSlideNum * scrollDistancePerSlide * -1;
      eventData = {
        fromSlideNum: currentSlideNum,
        fromSlide: $slides.eq(currentSlideNum),
        toSlideNum: targetSlideNum,
        toSlide: $slides.eq(targetSlideNum),
        wrapper: $wrapper,
        main: $main,
        transitionDuration: transitionDuration
      };
      $wrapper.trigger('scrollbegin.snappish', eventData);
      if (!doAnimate) {
        originalTransitionDuration = $main.css('transition-duration').toString();
        $main.css('transition-duration', '0');
      }
      $main.css('transform', "translate3d(0," + targetScrollDistance + "%,0)");
      currentSlideNum = targetSlideNum;
      triggerScrollEnd = function(eventData) {
        return $wrapper.trigger('scrollend.snappish', eventData);
      };
      if (doAnimate) {
        setTimeout(function() {
          return triggerScrollEnd(eventData);
        }, transitionDuration);
        return setTimeout(function() {
          return inTransition = false;
        }, transitionDuration + 300);
      } else {
        triggerScrollEnd(eventData);
        inTransition = false;
        return setTimeout(function() {
          return $main.css('transition-duration', originalTransitionDuration);
        }, 0);
      }
    };
    if (settings.mousewheelEnabled) {
      $wrapper.on('mousewheel', function(e, delta, deltaX, deltaY) {
        if (inTransition) {
          return;
        }
        if (deltaY < 0) {
          return scroll('down');
        } else if (deltaY > 0) {
          return scroll('up');
        }
      });
    }
    if (settings.swipeEnabled) {
      $.event.special.swipe.settings.threshold = settings.swipeThreshold;
      $wrapper.on('swipeup', function(e) {
        return scroll('down');
      });
      $wrapper.on('swipedown', function(e) {
        return scroll('up');
      });
    }
    $wrapper.on('scrollup.snappish', function(e) {
      var targetSlideNum;
      targetSlideNum = currentSlideNum - 1;
      if (targetSlideNum >= 0) {
        return scrollToSlide(targetSlideNum);
      }
    });
    $wrapper.on('scrolldown.snappish', function(e) {
      var targetSlideNum;
      targetSlideNum = currentSlideNum + 1;
      if (targetSlideNum < numberOfSlides) {
        return scrollToSlide(targetSlideNum);
      }
    });
    $wrapper.on('scrollto.snappish', function(e, opts) {
      var doAnimate, targetSlideNum;
      doAnimate = true;
      if (typeof opts !== 'undefined') {
        if (typeof opts === 'object') {
          targetSlideNum = opts.targetSlideNum;
          if (typeof opts.doAnimate !== 'undefined') {
            doAnimate = opts.doAnimate;
          }
        } else if (typeof opts === 'number' || typeof opts === 'string') {
          targetSlideNum = opts;
        } else {
          return;
        }
      }
      return scrollToSlide(targetSlideNum, doAnimate);
    });
    return $wrapper;
  };

  $.fn.snappish.defaults = {
    mainSelector: '.snappish-main',
    slidesSelector: '.snappish-main > *',
    mousewheelEnabled: true,
    swipeEnabled: true,
    swipeThreshold: 0.1
  };

}).call(this);
