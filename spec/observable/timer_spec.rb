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
      advance_by(2001, ignore: :on_complete) {
        should send_call.with(0).to(observer, :on_next)
      }
      advance_by(2001, ignore: :on_next) {
        should send_call.to(observer, :on_complete)
      }
    end

    context "timer x2 has passed" do
      advance_by(4001, ignore: :on_complete) {
        should send_call.with(0).to(observer, :on_next)
      }
      advance_by(4001, ignore: :on_next) {
        should send_call.to(observer, :on_complete)
      }
    end

  end

end