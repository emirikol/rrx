module Reactive::Observable
  class Map < Wrapper

    add_attributes :mapper

    #TODO need to handle array returned from @map.call ?
    observer_on_next do |value|
      begin
        new_value = @mapper.call(value)
      rescue Exception => e
        on_error(e)
      else
        #new_values.each {|v| @target.on_next(v)  }
        @target.on_next(new_value)
      end
    end

  end

end