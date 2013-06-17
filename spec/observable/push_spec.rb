require 'spec_helper'

describe Reactive::Observable do
  include Lets

  context 'timer(2000).push(timer(5000))' do
    before do
      o1 = Reactive::Observable.timer(2000)
      o2 = Reactive::Observable.timer(5000)
      @s = o1.push(o2)
      @s.subscribe(observer)
    end

    it 'does not fire before first timer' do
      observer[:on_next].should_not_receive(:call)
      advance_by(1000)
    end

    it 'fires once after first timer runs' do
      observer[:on_next].should_receive(:call).with(0)
      advance_by(2001)
    end

    it 'fires once after first but before the pushed one' do
      observer[:on_next].should_receive(:call).with(0)
      advance_by(4001)
    end

    context 'once both timers have run' do
      advance_by(7001).and do |expectation|
        expectation.next_should { be_called.exactly(:twice).with(0) }
        expectation.complete_should { be_called }
      end
    end

    context 'doesn\'t fire any more after both timers have run' do
      advance_by(20001).and do |expectation|
        expectation.next_should { be_called.exactly(2).times.with(0) }
        expectation.complete_should { be_called }
      end
    end

  end

  context 'interval(100).push(interval(222))' do
    before do
      o1 = Reactive::Observable.interval(100)
      o2 = Reactive::Observable.interval(222)
      @s = o1.push(o2)
      @s.subscribe(observer)
    end

    it 'doesn\'t fire on partial interval' do
      observer[:on_next].should_not_receive(:call)
      advance_by(99)
    end

    it 'fires once when first interval passed' do
      observer[:on_next].should_receive(:call).with(0)
      advance_by(101)
    end

    it 'fires for pushed interval, but not for original interval' do
      observer[:on_next].should_receive(:call).exactly(:twice).with(anything)
      advance_by(230)
    end
  end


  context 'when garbage collected' do
    before do
      o1 = Reactive::Observable.interval(100)
      o2 = Reactive::Observable.interval(222)
      @s = o1.push(o2)
      @s.subscribe(observer)
      remove_instance_variable(:@s)
      ObjectSpace.garbage_collect
    end
    it 'unsubscribes' do
      scheduler.advance_by(230)
    end
  end


end