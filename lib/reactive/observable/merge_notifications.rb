module Reactive::Observable

  class MergeNotifications < Wrapper

    #def initialize(*args)
    #  puts "!!!!"
    #  super
    #end

    def build_disposable_parent
      Reactive::Disposable::Composite.new # should be disposable#composite?
    end

    class Observer < Reactive::ObserverWrapper

      def on_next(value)
        @num_started = (@num_started || 0 ) + 1
        disposable = Reactive::Disposable::Wrapper.new
        weak_disposable = Reactive::AmbivalentRef.new(disposable)
        handle = value.subscribe(
            on_next: ->(val) {  @observer.on_next(val)  },
            on_complete: ->() { self.child_on_complete(weak_disposable)  },
            on_error: ->(error) { self.on_error(error)  }
        )
        disposable.target = handle
        wrap_with_parent(disposable)
      end


      def child_on_complete(child_disposable = nil)
        return if self.is_disposing?
        unwrap_parent(child_disposable) if child_disposable
        return on_complete_final if @num_started == 0
        @num_started -= 1
      end

      def on_complete
        child_on_complete
      end

      def on_complete_final
        @observer.on_complete
        unwrap
      end

    end

  end
end
