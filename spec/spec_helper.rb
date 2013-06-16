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

  def times
    self
  end

  def to(object, attr)
    @target = object[attr]
    @name = attr
    m = @target.should_receive(@method)
    m = m.exactly(@exactly).times if @exactly
    m.with(@with) if @with
    self
  end

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


#def error
#  @error ||= []
#end

def restart
  scheduler.restart
end

def advance_and_check_event_counts(events)
  events.each {|event| advance_and_check_event_count(*event) }
end

def advance_and_check_event_count(advance_by = nil, e_nxt = 0, e_complete = 0, e_error = 0, opts= {})
  [[:next_size, e_nxt], [:complete_size, e_complete], [:error_size, e_error]].each do |base, chg|
    it do
      expect {
        instance_eval(&opts[:proc]) if opts[:proc]
        scheduler.advance_by(advance_by)
      }.to change(self, base).by(chg)
    end
  end
  #[nxt.size, error.size, complete.size].should == [e_nxt, e_error, e_complete]
end

def next_size
  nxt.size
end
def error_size
  error.size
end
def complete_size
  complete.size
end



def subscribe(observable)
  observable.subscribe(
      :on_next => ->(v) { nxt << v;  },
      :on_complete => ->() { complete << 1  },
      :on_error => ->(e) { error << e  }
  )
end


def advance_by(ms, options = {}, &block)
  if block
    case options[:ignore]
      when :on_next, :on_error
        before { observer[options[:ignore]] = ->(v) {} }
      when :on_complete
        before { observer[:on_complete] = ->() {} }
    end
    after {
      scheduler.advance_by(ms)
    }
    it &block
  else
    scheduler.advance_by(ms)
  end
end

module Lets
  def self.included(context)
    context.let(:scheduler) { VirtualScheduler.new }
    #context.let(:observer) { {on_next: "Double (next)", on_error:  double('error'), on_complete:  double('complete') } }
    context.let(:observer) { {on_next: double('next'), on_error:  double('error'), on_complete:  double('complete') } }

    context.before do
      Reactive::Observable::Base.any_instance.stub(:scheduler).and_return(scheduler)
    end
  end
end
