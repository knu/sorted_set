# :markup: markdown

require 'set'

if defined?(JRUBY_VERSION)
  # JRuby has a built-in SortedSet (at least through JRuby 10).
  return if defined?(::SortedSet)
else
  require 'rbtree'
end

Object.instance_exec do
  # Undefine SortedSet for two reasons.
  #
  # 1. We should wipe out an existing implementation if Ruby 2.x loads
  #    this library after loading the standard set library which
  #    defines SortedSet.
  #
  # 2. Ruby >=3.0 (set >=1.0.0) sets autoload on SortedSet, and we
  #    shouldn't let the following reference to SortedSet fire it
  #    because it would end up requiring this library, leading to
  #    circular require.
  #
  remove_const :SortedSet if const_defined?(:SortedSet)
end

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
end

if defined?(JRUBY_VERSION)
  require_relative 'sorted_set/jruby'
elsif defined?(Set::CoreSet)
  require_relative 'sorted_set/ruby4'
else
  require_relative 'sorted_set/ruby3'
end

if defined?(JRUBY_VERSION) || defined?(Set::CoreSet)
  class Set
    # Set's equality cannot see SortedSet's separate backing store.
    module SortedSetEquality
      def ==(other)
        return super unless other.is_a?(SortedSet)

        size == other.size && other.all? { |o| include?(o) }
      end

      def eql?(other)
        return false if other.is_a?(SortedSet)

        super
      end
    end

    prepend SortedSetEquality

    private_constant :SortedSetEquality
  end
end
