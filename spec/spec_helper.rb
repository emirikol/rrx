require 'rrx'


class VirtualScheduler
  attr_accessor :now

  def initialize
    restart
  end

  def schedule_periodic(at, action, wrapper = Reactive::Disposable::Wrapper.new)
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
    add_action(@now + at, action)
    Reactive::Disposable::Closure.new { remove_action(action) }
  end

  def add_action(at, action)
    @actions << [at, action]
  end

  def remove_action(action)
    @actions.reject! {|at_ac|  at_ac[1] == action }
  end

  def sort_actions
    @actions.sort_by! {|at_ac| at_ac[0] }
  end

  def advance_by(ms)
    max = @now + ms
    while true
      sort_actions
      t, action = @actions[0]
      break if t.nil?
      break if t > max
      @now = t
      remove_action(action)
      action.call
    end
    @now = max
  end

  def restart
    @actions = []
    @now = 0
  end

end

class SendMessage
  def initialize(method)
    @method = method
  end

  def with(args)
    @with = args
    self
  end

  def exactly(times)
     @exactly = times
     self
  end

  def ordered
    @ordered = true
    self
  end

  def times
    self
  end

  def to(object, attr)
    @target = object[attr]
    @name = attr
    m = @target.should_receive(@method)
    m.exactly(@exactly).times if @exactly
    m.with(@with) if @with
    m.ordered if @ordered
    self
  end
  alias on to

  def matches?(that)
    true
  end

  def description
    "call #{@name}#{ " with #{@with}" if @with }#{ " #{@exactly} times"  if @exactly}"
  end

end

def send_call()
  SendMessage.new(:call)
end
alias be_called send_call

class MockObserver
  attr_reader :expectations

  def initialize(rspec, ms, description = nil )
    @description = description || "after #{ms} ms"
    @context = rspec
    @ms = ms
    @expectations =  {}
  end

  def and
    yield self
    observer_expectation = self
    ms = @ms
    @context.context @description do
      observer_expectation.expectations.each do |name, block|
        it {
          observer_expectation.modify(observer, name)
          instance_eval &block
        }
      end
      after {
        scheduler.advance_by(ms)
      }
    end
  end

  def complete(&block)
    @expectations[:on_complete] = block
    self
  end
  def complete_should(&matcher)
    #complete { should matcher.with(no_args).on(observer, :on_complete) }
    complete { should instance_eval(&matcher).with(no_args).on(observer, :on_complete) }
  end
  def error(&block)
    @expectations[:on_error] = block
    self
  end
  def error_should(&matcher)
    error { should instance_eval(&matcher).on(observer, :on_error) }
  end
  def next(&block)
    @expectations[:on_next] = block
    self
  end
  def next_should(&matcher)
    self.next { should instance_eval(&matcher).on(observer, :on_next) }
  end

  def modify(observer, for_event)
    [:on_complete, :on_error, :on_next].each do |event|
      next if for_event == event
      observer[event] = ->(*a) {} if @expectations[event]
    end
    observer[for_event]
  end
end
def advance_by_and(ms)

end


def restart
  scheduler.restart
end


def advance_by(ms, description = nil, &block)
  if self.respond_to?(:it)
    if block
      MockObserver.new(self, ms, description).and do |exp|
        exp.next &block
      end
    else
      MockObserver.new(self, ms, description)
    end
  else
    scheduler.advance_by(ms)
  end
end

module Lets
  def self.included(context)
    context.let(:scheduler) { VirtualScheduler.new }
    context.let(:observer) { {on_next: double('next'), on_error:  double('error'), on_complete:  double('complete') } }

    context.before do
      Reactive::Observable::Base.any_instance.stub(:scheduler).and_return(scheduler)
    end
  end
end
