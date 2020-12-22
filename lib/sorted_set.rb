# :markup: markdown

require 'set'
require 'rbtree'

##
# SortedSet implements a Set whose elements are sorted in ascending
# order (according to the return values of their `<=>` methods) when
# iterating over them.
#
# Every element in SortedSet must be *mutually comparable* to every
# other: comparison with `<=>` must not return nil for any pair of
# elements.  Otherwise ArgumentError will be raised.
#
# ## Example
#
# ```ruby
# require "sorted_set"
#
# set = SortedSet.new([2, 1, 5, 6, 4, 5, 3, 3, 3])
# ary = []
#
# set.each do |obj|
#   ary << obj
# end
#
# p ary # => [1, 2, 3, 4, 5, 6]
#
# set2 = SortedSet.new([1, 2, "3"])
# set2.each { |obj| } # => raises ArgumentError: comparison of Fixnum with String failed
# ```

class SortedSet < Set
  # Remove the existing implementation in case Ruby 2.x loads this
  # library after loading the standard set library which defines
  # SortedSet.
  if class_variable_defined?(:@@setup)
    # a hack to shut up warning
    alias_method :old_init, :initialize

    instance_methods(false).each { |m| remove_method(m) }
  end

  # Creates a SortedSet.  See Set.new for details.
  def initialize(*args)
    @hash = RBTree.new
    super
  end

  if class_variable_defined?(:@@setup)
    remove_class_variable(:@@setup)
    remove_class_variable(:@@mutex) if class_variable_defined?(:@@mutex)

    # a hack to shut up warning
    remove_method :old_init
  end
end
