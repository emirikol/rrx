module Reactive
  module Observable
    class Generate < Base
      attr_reader :init_value, :continue_perdicate, :step_action, :result_projection, :inter_step_duration

      def initialize(init_value, continue_perdicate, step_action, result_projection, inter_step_duration)
        @init_value, @continue_perdicate, @step_action, @result_projection, @inter_step_duration = init_value, continue_perdicate, step_action, result_projection, inter_step_duration
      end

      def run(observer)
        is_first = true
        state = @init_value
        duration = @inter_step_duration
        action = @step_action
        projection = @result_projection
        continue = @continue_perdicate

        init_duration = duration.call(state)
        self.schedule_periodic(init_duration, lambda do
          if is_first
            is_first = false
          else
            state = action.call(state)
          end
          result = projection.call(state)
          observer.on_next(result)

          if continue.call(state)
            duration.call(state)
          else
            observer.on_complete()
            nil
          end

        end)

      end

    end
  end
end