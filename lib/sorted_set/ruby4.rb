# Ruby >= 4.0: Set is a built-in class backed by C code and no longer
# uses @hash.  Subclassing Set automatically includes
# Set::SubclassCompatible, which delegates composite operations to
# primitive methods.  We override those primitives to use RBTree.

class SortedSet
  def initialize(enum = nil, &block)
    if block.nil? && enum.instance_of?(self.class)
      @tree = enum.instance_variable_get(:@tree).dup
      super(nil)
    else
      @tree = RBTree.new
      super
    end
  end

  def add(o)
    @tree[o] = true
    self
  end
  alias << add

  def delete(o)
    @tree.delete(o)
    self
  end

  def include?(o)
    @tree.has_key?(o)
  end
  alias member? include?

  def each(&block)
    block or return enum_for(__method__) { size }
    @tree.each_key(&block)
    self
  end

  def size
    @tree.size
  end
  alias length size

  def empty?
    @tree.empty?
  end

  def clear
    @tree.clear
    self
  end

  def replace(enum)
    if enum.instance_of?(self.class)
      @tree = enum.instance_variable_get(:@tree).dup
    else
      clear
      merge(enum)
    end
    self
  end

  def to_a
    @tree.keys
  end

  def hash
    @tree.keys.hash
  end

  def ==(other)
    return true if equal?(other)

    if other.is_a?(SortedSet)
      @tree == other.instance_variable_get(:@tree)
    elsif other.is_a?(Set)
      size == other.size && other.all? { |o| include?(o) }
    else
      false
    end
  end

  def eql?(other)
    other.instance_of?(self.class) &&
      @tree.keys.eql?(other.instance_variable_get(:@tree).keys)
  end

  def freeze
    @tree.freeze
    super
  end

  def initialize_dup(orig)
    super
    @tree = orig.instance_variable_get(:@tree).dup
  end

  def initialize_clone(orig, freeze: nil)
    super
    # When freeze is nil, clone preserves the frozen state of orig.
    @tree = orig.instance_variable_get(:@tree).clone(freeze: freeze.nil? ? orig.frozen? : freeze)
  end
end
