module Reactive::Observable

  class Grep < Wrapper

    add_attributes :predicate

    observer_on_next do |value|
      begin
        should_pass = @predicate.call(value)
      rescue Exception => e
        on_error.call(e)
      else
        @observer.on_next(value) if should_pass
      end
    end
  end

end