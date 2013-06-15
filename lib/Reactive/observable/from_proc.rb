module Reactive

  module Observable

    class FromProc < Observable::Base
      def initialize(&proc)
        @on_subscribe = proc
      end

      def run(observer)
        @on_subscribe.call(observer)
      end
    end

  end

end