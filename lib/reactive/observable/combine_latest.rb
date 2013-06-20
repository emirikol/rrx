module Reactive::Observable

  class CombineLatest < DoubleWrapper

    def initialize(options)
      [1,2].each do |i|
        options[:"o#{i}"] = options[:"o#{i}"].map {|v|  [i, v] }
      end
      super
    end

    class Observer < Reactive::ObserverWrapper

      def on_next(child_value)
        child, value = child_value
        instance_variable_set(:"@value#{child}", value)
        if defined?(@value1) && defined?(@value2)
          @observer.on_next([@value1, @value2])
        end

      end

      #complete when both are completed??
      def on_complete
        @observer.on_complete if @completed == 1
        @completed ||= 1
      end

    end

  end

end