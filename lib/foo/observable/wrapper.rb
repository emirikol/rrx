module Reactive::Observable

  class Wrapper < Composite
    add_attributes :target

    def initial_subscriptions
      [@target]
    end
  end
end
