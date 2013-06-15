class Reactive::Observable::Grep < Reactive::Observable::Wrapper

  add_attributes :predicate

  #def initialize(value, predicate)
  #  @predicate = predicate
  #  super(value)
  #end

  #def observer_args(observer, parent)
  #  [observer, parent, @predicate]
  #end

  class Observer < Reactive::ObserverWrapper
    attr_reader :predicate

    #def initialize(value, parent, opts={})
    #  @predicate = opts[:predicate]
    #  super(value, parent)
    #end

    def on_next(value)
      begin
        should_pass = @predicate.call(value)
      rescue Exception => e
        pp e
        on_error.call(e)
      else
        @target.on_next(value) if should_pass
      end
    end

  end

end