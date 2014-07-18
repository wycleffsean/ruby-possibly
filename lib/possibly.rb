module Maybe
  # Parent class for Maybe::Some and Maybe::None. You should never
  # instantiate this class.
  class Maybe
    ([:each] + Enumerable.instance_methods).each do |enumerable_method|
      define_method(enumerable_method) do |*args, &block|
        res = __enumerable_value.send(enumerable_method, *args, &block)
        res.respond_to?(:each) ? Maybe(res.first) : (res.nil? ? Maybe(res) : res)
      end
    end

    def to_ary
      __enumerable_value
    end
    alias_method :to_a, :to_ary

    def ==(other)
      other.class == self.class
    end
    alias_method :eql?, :==
  end

  # Represents a non-empty value
  class Some < Maybe
    def initialize(value)
      @value = value
    end

    def get
      @value
    end

    def or_else(*)
      @value
    end

    # rubocop:disable PredicateName
    def is_some?
      true
    end

    def is_none?
      false
    end
    # rubocop:enable PredicateName

    def ==(other)
      super && get == other.get
    end
    alias_method :eql?, :==

    def method_missing(method_sym, *args, &block)
      return None.new unless @value.respond_to? method_sym
      map { |value| value.send(method_sym, *args, &block) }
    end

    private

    def __enumerable_value
      [@value]
    end
  end

  # Represents an empty value
  class None < Maybe
    def get
      fail 'No such element'
    end

    def or_else(els = nil)
      block_given? ? yield : els
    end

    # rubocop:disable PredicateName
    def is_some?
      false
    end

    def is_none?
      true
    end
    # rubocop:enable PredicateName

    def method_missing(*)
      None.new
    end

    private

    def __enumerable_value
      []
    end
  end
end

# rubocop:disable MethodName
def Maybe(value)
  if value.nil? || (value.respond_to?(:length) && value.length == 0)
    None
  else
    Some(value)
  end
end

def Some(value)
  Maybe::Some.new(value)
end

def None
  Maybe::None.new
end

None = None()
# rubocop:enable MethodName
