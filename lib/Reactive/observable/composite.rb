module Reactive::Observable

  class Composite < Base

    def run(observer)
      disposable_parent = build_disposable_parent
      observer_class = self.class.const_get('Observer')
      observer_wrapper =  observer_class.new(*observer_args(observer, disposable_parent))

      disposables = initial_subscriptions.map {|o|  o.subscribe_observer(observer_wrapper) }

      fill_disposable_parent(disposable_parent, disposables)
      disposable_parent
    end

    def fill_disposable_parent(parent, disposables)
      parent.target = disposables unless parent.target
    end

    def initial_subscriptions
      []
    end

    #def observer_args(observer, parent)
    #  [observer, parent]
    #end

    private
    def build_disposable_parent
      Reactive::Disposable::Wrapper.new
    end
  end

end