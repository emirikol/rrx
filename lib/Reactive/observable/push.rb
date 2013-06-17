module Reactive::Observable

  class Push < Wrapper
    add_attributes :o2

    def initial_subscriptions
      [@target]
    end


    class Observer < Reactive::ObserverWrapper

      def on_complete
        if @o2
          next_observable = @o2
          @o2 = nil
          disposable = next_observable.subscribe_observer(self)
          wrap_with_parent(disposable) if @observer
        else
          @observer.on_complete
          unwrap
        end
      end

    end

  end

end