module Reactive::Observable

  class Count < Wrapper

    observer_on_next do |value|
      @counter ||= 0
      @counter += 1
      @observer.on_next(@counter)
    end

  end

end