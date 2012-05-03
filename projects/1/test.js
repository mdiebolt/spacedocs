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