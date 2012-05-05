/**
Creates and returns a copy of the array. The copy contains
the same objects.

    a = ["a", "b", "c"]
    b = a.copy()

    # their elements are equal
    a[0] == b[0] && a[1] == b[1] && a[2] == b[2]
    # => true

    # but they aren't the same object in memory
    a === b
    # => false

@returns {Array} A new array that is a copy of the array
*/

Array.prototype.copy = function() {
  return this.concat();
};

/**
Empties the array of its contents. It is modified in place.

    fullArray = [1, 2, 3]
    fullArray.clear()
    fullArray
    # => []

@name clear
@methodOf Array#
@returns {Array} this, now emptied.
*/

Array.prototype.clear = function() {
  this.length = 0;
  return this;
};

/**
Flatten out an array of arrays into a single array of elements.

    [[1, 2], [3, 4], 5].flatten()
    # => [1, 2, 3, 4, 5]

    # won't flatten twice nested arrays. call
    # flatten twice if that is what you want
    [[1, 2], [3, [4, 5]], 6].flatten()
    # => [1, 2, 3, [4, 5], 6]

@name flatten
@methodOf Array#
@returns {Array} A new array with all the sub-arrays flattened to the top.
*/

Array.prototype.flatten = function() {
  return this.inject([], function(a, b) {
    return a.concat(b);
  });
};

/**
Remove the first occurrence of the given object from the array if it is
present. The array is modified in place.

    a = [1, 1, "a", "b"]
    a.remove(1)
    # => 1

    a
    # => [1, "a", "b"]

@name remove
@methodOf Array#
@param {Object} object The object to remove from the array if present.
@returns {Object} The removed object if present otherwise undefined.
*/

Array.prototype.remove = function(object) {
  var index;
  index = this.indexOf(object);
  if (index >= 0) {
    return this.splice(index, 1)[0];
  } else {
    return;
  }
};

/**
Bindable module.

<code><pre>
player = Core
  x: 5
  y: 10

player.bind "update", ->
  updatePlayer()
# => Uncaught TypeError: Object has no method 'bind'

player.include(Bindable)

player.bind "update", ->
  updatePlayer()
# => this will call updatePlayer each time through the main loop
</pre></code>

@name Bindable
@module
@constructor
*/
var Bindable,
  __slice = Array.prototype.slice;

Bindable = function() {
  var eventCallbacks;
  eventCallbacks = {};
  return {
    /**
    The bind method adds a function as an event listener.

    <code><pre>
    # this will call coolEventHandler after
    # yourObject.trigger "someCustomEvent" is called.
    yourObject.bind "someCustomEvent", coolEventHandler

    #or
    yourObject.bind "anotherCustomEvent", ->
      doSomething()
    </pre></code>

    @name bind
    @methodOf Bindable#
    @param {String} event The event to listen to.
    @param {Function} callback The function to be called when the specified event
    is triggered.
    */
    bind: function(event, callback) {
      eventCallbacks[event] = eventCallbacks[event] || [];
      return eventCallbacks[event].push(callback);
    },
    /**
    The unbind method removes a specific event listener, or all event listeners if
    no specific listener is given.

    <code><pre>
    #  removes the handler coolEventHandler from the event
    # "someCustomEvent" while leaving the other events intact.
    yourObject.unbind "someCustomEvent", coolEventHandler

    # removes all handlers attached to "anotherCustomEvent"
    yourObject.unbind "anotherCustomEvent"
    </pre></code>

    @name unbind
    @methodOf Bindable#
    @param {String} event The event to remove the listener from.
    @param {Function} [callback] The listener to remove.
    */
    unbind: function(event, callback) {
      eventCallbacks[event] = eventCallbacks[event] || [];
      if (callback) {
        return eventCallbacks[event].remove(callback);
      } else {
        return eventCallbacks[event] = [];
      }
    },
    /**
    The trigger method calls all listeners attached to the specified event.

    <code><pre>
    # calls each event handler bound to "someCustomEvent"
    yourObject.trigger "someCustomEvent"
    </pre></code>

    @name trigger
    @methodOf Bindable#
    @param {String} event The event to trigger.
    @param {Array} [parameters] Additional parameters to pass to the event listener.
    */
    trigger: function() {
      var callbacks, event, parameters, self;
      event = arguments[0], parameters = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
      callbacks = eventCallbacks[event];
      if (callbacks && callbacks.length) {
        self = this;
        return callbacks.each(function(callback) {
          return callback.apply(self, parameters);
        });
      }
    }
  };
};