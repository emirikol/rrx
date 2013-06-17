module Reactive::Observable

  class Unshift < Wrapper
    add_attributes :unshifted

    def initial_subscriptions
      [@unshifted]
    end

    class Observer < Reactive::ObserverWrapper

      def on_complete
        if @unshifted
          @unshifted = nil
          disposable = @target.subscribe_observer(self)
          wrap_with_parent(disposable) if @observer
        else
          @observer.on_complete
          unwrap
        end
      end

    end

  end

end