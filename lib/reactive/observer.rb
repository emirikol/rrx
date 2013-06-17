module Reactive
  class Observer

      def initialize(handlers)
        @handlers = handlers
      end

      def on_next(value)
        @handlers[:on_next].call(value)
      end

      def on_complete
        @handlers[:on_complete].call()
      end

      def on_error(error)
        @handlers[:on_error].call(error)
        unwrap
      end

      def unwrap
        @handlers = nil
      end


  end

  class EmptyObserver

    def on_next(value); end
    def on_complete; end
    def on_error(error); end

  end

end