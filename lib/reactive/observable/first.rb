module Reactive::Observable

  class First < Wrapper
    add_attributes :count

    class Observer < Reactive::ObserverWrapper

      def initialize(*args)
        @taken = 0
        super
      end

      #??? count is nilled (since it's an attribute), but we might not want it to...
      #can be less change attribute nilling on unwrap to opt in/out or write unwrap method?
      #or leave as is because everything is sort of perfect?
      def on_next(value)
        @observer.on_next(value)
        @taken += 1
        on_complete if @taken == @count
      end

    end

  end

end