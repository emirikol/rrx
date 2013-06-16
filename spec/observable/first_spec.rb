require 'spec_helper'

describe Reactive::Observable::First do
  include Lets

  context '#first(3) from interval' do
    before do
      @s = Reactive::Observable::First.new(target: Reactive::Observable.interval(1000), count: 3)
      @s.subscribe(observer)
    end

    context 'after one interval' do
      advance_by(1001) {
        should send_call.with(0).to(observer, :on_next)
      }
    end

    context 'after 3 intervals' do
      advance_by(3001, ignore: :on_complete) {
        should send_call.exactly(3).times.with(kind_of(Fixnum)).to(observer, :on_next)
      }
      advance_by(3001, ignore: :on_next) {
        should send_call.with(no_args).to(observer, :on_complete)
      }
    end


    context 'after 4 intervals' do
      advance_by(4001, ignore: :on_complete) {
        should send_call.exactly(3).times.with(kind_of(Fixnum)).to(observer, :on_next)
      }
    end

  end

  context  do
    it 'take 1 from 1', :focus => true do
      @s = Reactive::Observable::First.new(target:  Reactive::Observable.once(1), count: 1 )
      observer[:on_next].should_receive(:call).with(1)
      observer[:on_complete].should_receive(:call).with(no_args())
      @s.subscribe(observer)
    end

  end


end