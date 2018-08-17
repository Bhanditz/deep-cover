# frozen_string_literal: true

require_relative 'variables'
require_relative 'literals'

module DeepCover
  class Node
    class Kwbegin < Node
      has_extra_children instructions: Node,
                         is_statement: true

      def is_statement
        false
      end
    end

    class Return < Node
      has_extra_children values: Node
      # TODO
    end

    class Super < Node
      check_completion
      has_extra_children arguments: Node
      # TODO
    end
    Zsuper = Super # Zsuper is super with no parenthesis (same arguments as caller)

    class Yield < Node
      has_extra_children arguments: Node
      # TODO
    end

    class Break < Node
      has_extra_children arguments: Node
      # TODO: Anything special needed for the arguments?

      def flow_completion_count
        0
      end
    end

    class Next < Node
      has_extra_children arguments: Node
      # TODO: Anything special needed for the arguments?

      def flow_completion_count
        0
      end
    end

    class Alias < Node
      check_completion
      has_child alias: [Sym, Dsym, Gvar, BackRef]
      has_child original: [Sym, Dsym, Gvar, BackRef]
      # TODO: test
    end

    class NeverEvaluated < Node
      has_extra_children whatever: [:any], remap: {Parser::AST::Node => NeverEvaluated}

      def executable?
        false
      end
    end

    class Defined < Node
      has_child code: {Parser::AST::Node => NeverEvaluated}
      # TODO: test
    end

    class Undef < Node
      check_completion
      has_extra_children arguments: [Sym, Dsym]
      # TODO: test
    end

    class Return < Node
      include ExecutedAfterChildren

      def flow_completion_count
        0
      end
    end
  end
end
