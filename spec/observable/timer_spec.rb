require 'spec_helper'

describe Reactive::Observable do
  include Lets

  context '#timer(2000)' do
    before do
      @s = Reactive::Observable.timer(2000)
      @s.subscribe(observer)
    end

    #TODO shared example?
    it 'doesn\'t fire on subscribe' do
      observer[:on_next].should_not_receive(:call)
    end

    it "doesn't fire before timer" do
      observer[:on_next].should_not_receive(:call)
    end

    context 'timer has passed' do
      advance_by(2001).and do |its|
        its.next_should { be_called.with(0) }
        its.complete_should { be_called }
      end
    end

    context "timer x2 has passed" do
      advance_by(4001).and do |its|
        its.next_should { be_called.with(0) }
        its.complete_should { be_called }
      end
    end

  end

end