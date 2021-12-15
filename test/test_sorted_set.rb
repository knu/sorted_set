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

  def test_enumerable_to_set
    ary = [2,5,4,3,2,1,3]

    set = ary.to_set(SortedSet)
    assert_instance_of(SortedSet, set)
    assert_equal([1,2,3,4,5], set.to_a)

    set = ary.to_set(SortedSet) { |o| o * -2 }
    assert_instance_of(SortedSet, set)
    assert_equal([-10,-8,-6,-4,-2], set.to_a)
  end

  def test_include
    s = SortedSet[4,5,3,1,2]
    assert_equal(true, s.include?(4))
    assert_equal(false, s.include?(6))
  end
end
