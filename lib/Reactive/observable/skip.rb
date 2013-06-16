module Reactive::Observable

  class Skip < Wrapper
    add_attributes :count

    class Observer < Reactive::ObserverWrapper

      def initialize(*args)
        @skipped = 0
        super
      end

      def on_next(value)
        if @skipped == @count
          @target.on_next(value)
        else
          @skipped += 1
        end
      end

    end

  end

end