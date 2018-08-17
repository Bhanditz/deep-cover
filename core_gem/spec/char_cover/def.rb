### Def
#### Simple
    module M
      def foo
        42
#>X
      end
    end

#### With args
    module M
      def foo(a, b)
#>           ------
      end
      def baz(a, b, c=1, *rest)
#>           ---------x--------
      end
      def bar(a, b, c=1, *rest, d: 2, **h)
#>           ---------x------------x------
      end
    end

#### With args without parens
    module M
      def foo a, b

      end
      def baz a, b, c=1, *rest
#>           ---------x-------
      end
      def bar a, b, c=1, *rest, d: 2, **h
#>           ---------x------------x-----
      end
    end

#### Called
    class C
      def bar(a, b, c=1, *rest, d: 2, **h)
        42
      end
    end
    C.new.bar(1,2)

#### Raising
    module Frozen
      freeze
      def foo
      end
      42
#>X
    end rescue nil

#### Empty body
    def empty_method; end
    assert_equal nil, empty_method
    assert_equal DeepCover::Node::EmptyBody, current_ast[0].body.class
    assert_equal 1, current_ast[0].body.execution_count

### Singleton def
#### Simple
    o = {}
    def o.some_method
      42
#>X
    end

#### With args
    o = {}
    def o.foo(a, b, c=1, *rest, d: 2, **h)
#>           ---------x------------x------
    end

#### Called
    o = {}
    def o.foo(a, b, c=1, *rest, d: 2, **h)
    end
    o.foo(1,2)

#### of const
    def Integer.some_method; end

#### of self
    def self.some_method; end

#### of send
    def dummy_method.some_method; end

#### of send chain
    def (Array.new).some_method; end

#### with raising singleton
    def does_not_exist.some_method; end rescue nil
#>  xxx               xxxxxxxxxxxx- ---

#### Raising
    module Frozen; freeze; end;
    (def Frozen.foo; end; 42) rescue nil
#>  -              - ---- xx-

#### Empty body
    def self.no_body; end
    assert_equal nil, no_body
