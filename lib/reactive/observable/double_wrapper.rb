module Reactive
  module Observable
    class  DoubleWrapper < Composite

    add_attributes :o1, :o2

    #def initialize(o1, o2)
    #  @o1, @o2, = o1, o2
    #end

    def initial_subscriptions
      [@o1, @o2]
    end

    end
  end
end