module DeepCover
  class Node
    class Args < Node
      has_children rest: :arguments
      def executable?
        false
      end
    end

    class Arg < Node
      has_children :name

      def executable?
        false
      end
    end
    Kwrestarg = Kwarg = Restarg = Arg

    class Optarg < Node
      has_children :name, :default

      def executable?
        false
      end
    end
    Kwoptarg = Optarg
  end
end
