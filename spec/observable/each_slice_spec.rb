require 'spec_helper'

describe Reactive::Observable do

  include Lets

  context '#each_slice(2) from interval(1000)' do
    before do
      @s = Reactive::Observable.interval(1000).
          each_slice(2)
      @s.subscribe(observer)
    end

    context 'partial interval' do
      advance_by(100) do
        observer[:on_next].should_not_receive(:call)
      end
    end

    context 'first interval' do
      advance_by(1000) do
        observer[:on_next].should_not_receive(:call)
      end
    end

    context 'buffer filled' do
      advance_by(2000) do
        should send_call.with([0, 1]).on(observer, :on_next)
      end
    end

    context 'buffer filled twice' do
      advance_by(4000) do
        should send_call.with([0, 1]).on(observer, :on_next).ordered
        should send_call.with([2, 3]).on(observer, :on_next).ordered
      end
    end

  end

  context '#each_slice(2, skip: 1) from interval(1000)' do
    before do
      @s = Reactive::Observable.interval(1000).
          each_slice(2, skip: 1)
      @s.subscribe(observer)
    end
    context 'buffer filled twice' do
      advance_by(4000) do
        should send_call.with([1]).on(observer, :on_next).ordered
        should send_call.with([3]).on(observer, :on_next).ordered
      end
    end
  end

  context "observable size not divisible by slice size" do
    before do
      @s = Reactive::Observable.from_array([1, 2, 3]).
          each_slice(2)
    end

    advance_by(0).and do |its|
      its.next {
        should send_call.with([1, 2]).on(observer, :on_next).ordered
        should send_call.with([3]).on(observer, :on_next).ordered
      }
      its.complete_should { be_called  }
    end

    after do
      @s.subscribe(observer)
    end
  end



end