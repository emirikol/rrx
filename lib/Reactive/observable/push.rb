module Reactive::Observable

  class Push < Composite
    add_attributes :o1, :o2

    #def initialize(o1, o2)
    #  @o1, @o2 = o1, o2
    #end

    def initial_subscriptions
      [@o1]
    end

    def observer_args(observer, parent)
        [observer, parent, @o2]
    end

    class Observer < Reactive::ObserverWrapper
      attr_reader :next_observable

      def initialize(observer, parent, ob)
        @next_observable = ob
        super(observer, parent)
      end

      def on_complete
        if @next_observable
          next_observable = @next_observable
          @next_observable = nil
          disposable = next_observable.subscribe_observer(self)
          wrap_with_parent(disposable) if @target
        else
          @target.on_complete
          unwrap
        end
      end

      def unwrap
        @next_observable = nil
        super
      end

    end

  end

end