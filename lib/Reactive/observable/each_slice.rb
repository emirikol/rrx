module Reactive::Observable

  class EachSlice < Wrapper
    add_attributes :count, skip: 0

    class Observer < Reactive::ObserverWrapper

      def initialize(*args)
        @buffer = []
        super
      end

      def on_next(value)
        @buffer << value
        if @buffer.size == @count
          buffer = @buffer
          @buffer = []
          @observer.on_next(buffer[@skip..-1])
        end
      end

      def on_complete
        #TODO is - skip correct or should empty array be passed?
        @observer.on_next(@buffer[@skip..-1]) if @buffer.size - @skip > 0
        @observer.on_complete
      end

    end

  end

end