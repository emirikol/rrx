module Reactive
  class Scheduler

    def schedule_periodic(at, action, wrapper = Disposable::Wrapper.new)
      return unless wrapper
      callback = lambda do
        new_at = action.()
        if new_at #defined ~
          schedule_periodic(new_at, action, wrapper)
        else
          wrapper.unwrap
        end
      end
      wrapper.target = schedule_once(at, callback)

    end

    def schedule_once(at, action)
      EventMachine.add_timer(at / 1000.0, action)
    end

  end
end