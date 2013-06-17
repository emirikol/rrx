module Reactive::Observable

  class Skip < Wrapper
    add_attributes :count


   observer_on_next do |value|
      @skipped ||= 0
      if @skipped == @count
        @observer.on_next(value)
      else
        @skipped += 1
      end
    end

  end

end