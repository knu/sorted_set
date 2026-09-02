# JRuby with Ruby >= 4.0 compat: Set is a built-in class and SortedSet
# has been removed.  Subclassing Set auto-includes
# Set::SubclassCompatible.  We use java.util.TreeSet as the backing
# store instead of RBTree (a C extension unavailable on JRuby).

require 'java'

class SortedSet
  def initialize(enum = nil, &block)
    if block.nil? && enum.instance_of?(self.class)
      @tree = enum.instance_variable_get(:@tree).dup
      super(nil)
    else
      @tree = java.util.TreeSet.new
      super
    end
  end

  def add(o)
    check_frozen
    @tree.add(o)
    self
  end
  alias << add

  def delete(o)
    check_frozen
    @tree.remove(o)
    self
  end

  def include?(o)
    @tree.contains(o)
  rescue Java::JavaLang::ClassCastException
    # TreeSet rejects some Ruby-comparable cross-class values, such as
    # Integer and Float.
    @tree.to_a.any? { |element| (element <=> o) == 0 }
  end
  alias member? include?

  def each(&block)
    block or return enum_for(__method__) { size }
    @tree.each(&block)
    self
  end

  def size
    @tree.size
  end
  alias length size

  def empty?
    @tree.is_empty
  end

  def clear
    check_frozen
    @tree.clear
    self
  end

  def replace(enum)
    check_frozen
    if enum.instance_of?(self.class)
      @tree = enum.instance_variable_get(:@tree).dup
    else
      @tree.clear
      merge(enum)
    end
    self
  end

  def to_a
    @tree.to_a
  end

  def hash
    @tree.to_a.hash
  end

  def ==(other)
    return true if equal?(other)

    if other.is_a?(Set)
      size == other.size && other.all? { |o| include?(o) }
    else
      false
    end
  end

  def eql?(other)
    other.instance_of?(self.class) &&
      @tree.to_a.eql?(other.instance_variable_get(:@tree).to_a)
  end

  def freeze
    super
  end

  def initialize_dup(orig)
    super
    @tree = orig.instance_variable_get(:@tree).dup
  end

  def initialize_clone(orig, freeze: nil)
    super
    @tree = orig.instance_variable_get(:@tree).dup
  end

  private

  # Java objects do not honor Ruby's freeze semantics, so we must
  # guard mutation methods ourselves.
  def check_frozen
    raise FrozenError, "can't modify frozen #{self.class}: #{inspect}" if frozen?
  end
end
