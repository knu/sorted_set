require 'test/unit'
require 'sorted_set'

class TC_SortedSet < Test::Unit::TestCase
  def test_sortedset
    s = SortedSet[4,5,3,1,2]

    a = s.to_a
    assert_equal([1,2,3,4,5], a)
    a << -1
    assert_equal([1,2,3,4,5], s.to_a)

    prev = nil
    s.each { |o| assert(prev < o) if prev; prev = o }
    assert_not_nil(prev)

    s.map! { |o| -2 * o }

    assert_equal([-10,-8,-6,-4,-2], s.to_a)

    prev = nil
    ret = s.each { |o| assert(prev < o) if prev; prev = o }
    assert_not_nil(prev)
    assert_same(s, ret)

    s = SortedSet.new([2,1,3]) { |o| o * -2 }
    assert_equal([-6,-4,-2], s.to_a)

    s = SortedSet.new(['one', 'two', 'three', 'four'])
    a = []
    ret = s.delete_if { |o| a << o; o.start_with?('t') }
    assert_same(s, ret)
    assert_equal(['four', 'one'], s.to_a)
    assert_equal(['four', 'one', 'three', 'two'], a)

    s = SortedSet.new(['one', 'two', 'three', 'four'])
    a = []
    ret = s.reject! { |o| a << o; o.start_with?('t') }
    assert_same(s, ret)
    assert_equal(['four', 'one'], s.to_a)
    assert_equal(['four', 'one', 'three', 'two'], a)

    s = SortedSet.new(['one', 'two', 'three', 'four'])
    a = []
    ret = s.reject! { |o| a << o; false }
    assert_same(nil, ret)
    assert_equal(['four', 'one', 'three', 'two'], s.to_a)
    assert_equal(['four', 'one', 'three', 'two'], a)
  end

  def test_each
    ary = [1,3,5,7,10,20]
    set = SortedSet.new(ary)

    ret = set.each { |o| }
    assert_same(set, ret)

    e = set.each
    assert_instance_of(Enumerator, e)

    assert_nothing_raised {
      set.each { |o|
        ary.delete(o) or raise "unexpected element: #{o}"
      }

      ary.empty? or raise "forgotten elements: #{ary.join(', ')}"
    }

    assert_equal(6, e.size)
    set << 42
    assert_equal(7, e.size)
  end

  def test_freeze
    orig = set = SortedSet[3,2,1]
    assert_equal false, set.frozen?
    set << 4
    assert_same orig, set.freeze
    assert_equal true, set.frozen?
    assert_raise(FrozenError) {
      set << 5
    }
    assert_equal 4, set.size

    # https://bugs.ruby-lang.org/issues/12091
    assert_nothing_raised {
      assert_equal [1,2,3,4], set.to_a
    }
  end

  def test_freeze_dup
    set1 = SortedSet[1,2,3]
    set1.freeze
    set2 = set1.dup

    assert_not_predicate set2, :frozen?
    assert_nothing_raised {
      set2.add 4
    }
  end

  def test_freeze_clone
    set1 = SortedSet[1,2,3]
    set1.freeze
    set2 = set1.clone

    assert_predicate set2, :frozen?
    assert_raise(FrozenError) {
      set2.add 5
    }
  end

  def test_enumerable_to_sorted_set
    ary = [2,5,4,3,2,1,3]

    set = SortedSet.new(ary)
    assert_instance_of(SortedSet, set)
    assert_equal([1,2,3,4,5], set.to_a)

    set = SortedSet.new(ary) { |o| o * -2 }
    assert_instance_of(SortedSet, set)
    assert_equal([-10,-8,-6,-4,-2], set.to_a)
  end

  def test_new_from_sorted_set
    set1 = SortedSet[3,1,2]
    set2 = SortedSet.new(set1)
    assert_equal([1,2,3], set2.to_a)
    assert_nothing_raised { set2.add 4 }
    assert_equal([1,2,3,4], set2.to_a)
    assert_equal([1,2,3], set1.to_a)

    set2 = SortedSet.new(set1) { |o| o * 2 }
    assert_equal([2,4,6], set2.to_a)

    set1.freeze
    set3 = SortedSet.new(set1)
    assert_equal([1,2,3], set3.to_a)
    assert_not_predicate set3, :frozen?
    assert_nothing_raised { set3.add 4 }
  end

  def test_equality
    omit('Ruby 4.0 specific') unless SortedSet.instance_method(:==).owner == SortedSet

    set1 = SortedSet[1,2,3]
    set2 = SortedSet[3,2,1]
    set3 = SortedSet[1,2]
    subclass = Class.new(SortedSet)
    set4 = subclass.new([3,2,1])

    assert_operator(set1, :==, set2)
    assert_not_operator(set1, :==, set3)
    assert_operator(set1, :eql?, set2)
    assert_not_operator(set1, :eql?, set3)
    assert_operator(set1, :==, set4)
    assert_operator(set4, :==, set1)
    assert_not_operator(set1, :eql?, set4)
    assert_not_operator(set4, :eql?, set1)

    assert_equal(set1.hash, set2.hash)

    assert_equal(:first, { set1 => :first, set3 => :second }[set2])
    assert_equal(:first, { first: set1, second: set3 }.key(set2))

    integer_set = SortedSet[1]
    float_set = SortedSet[1.0]
    assert_operator(integer_set, :==, float_set)
    assert_not_operator(integer_set, :eql?, float_set)
    assert_nil({ integer_set => :match }[float_set])

    element_class = Class.new do
      include Comparable

      attr_reader :value

      def initialize(value)
        @value = value
      end

      def <=>(other)
        value <=> other.value
      end
    end

    assert_operator(SortedSet[element_class.new(1)], :==, SortedSet[element_class.new(1)])
  end

  def test_equality_with_set
    omit('Ruby 4.0 specific') unless SortedSet.instance_method(:==).owner == SortedSet

    sorted_set = SortedSet[1,2,3]

    assert_operator(SortedSet[], :==, Set[])
    assert_operator(sorted_set, :==, Set[3,2,1])
    assert_not_operator(sorted_set, :==, Set[1,2])
    assert_not_operator(sorted_set, :==, Set[1,2,4])
    assert_operator(SortedSet[1], :==, Set[1.0])
    assert_include(SortedSet[1], 1.0)
    assert_not_operator(sorted_set, :==, [1,2,3])
    assert_not_operator(sorted_set, :eql?, Set[1,2,3])
  end

  def test_set_equality_with_sorted_set
    omit('Ruby 4.0 specific') unless SortedSet.instance_method(:==).owner == SortedSet

    sorted_set = SortedSet[1,2,3]

    assert_operator(Set[], :==, SortedSet[])
    assert_operator(Set[3,2,1], :==, sorted_set)
    assert_not_operator(Set[1,2], :==, sorted_set)
    assert_not_operator(Set[1,2,4], :==, sorted_set)
    assert_not_operator(Set[1.0], :==, SortedSet[1])
    assert_not_operator(Set[], :eql?, SortedSet[])
    assert_not_operator(Set[1,2,3], :eql?, sorted_set)
    assert_nil({ Set[] => :match }[SortedSet[]])
  end
end
