module Reactive
  module Observable
  class Merge < DoubleWrapper

    class Observer < ObserverWrapper
      attr_accessor :num_completed

      def initialize(*args)
        @num_completed = 0
        super
      end

      def on_complete
        if num_completed == 0
          self.num_completed = 1
        else
          self.target.on_complete
          unwrap
        end
      end

    end

  end
  end
end