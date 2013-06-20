require 'spec_helper'

describe Reactive::Observable do
  include Lets

  def fire_at(time,value)
    Reactive::Observable.timer(time).map {|i| value }
  end

  context '#combine_latest' do
    before do
      o = Reactive::Observable.interval(100)
      o2 = Reactive::Observable.merge(
        fire_at(150,10),
        fire_at(350,20)
      )
      o.combine_latest(o2).subscribe(observer)
    end

    advance_by(100, 'only one stream fired') do
      observer[:on_next].should_not_receive(:call)
    end

    advance_by(150, 'both streams fired').and do |its|
      its.next_should { be_called.with([0,10]) }
    end

    advance_by(200, 'streams fired: twice, once').and do |its|
      its.next {
        should be_called.exactly(1).times.with(any_args).on(observer, :on_next).ordered
        should be_called.with([1,10]).to(observer, :on_next).ordered
      }
    end

    advance_by(300, 'streams fired: thrice, once').and do |its|
      its.next {
        should be_called.exactly(2).times.with(any_args).on(observer, :on_next).ordered
        should be_called.with([2,10]).on(observer, :on_next).ordered
      }
    end

    advance_by(350, 'streams fired: thrice, twice').and do |its|
      its.next {
        should be_called.exactly(3).times.with(any_args).on(observer, :on_next).ordered
        should be_called.with([2,20]).on(observer, :on_next).ordered
      }
    end


    # test complete?

  end

end


##              o1: 1--------2----3------->
##              o2: ----4--------------5-->
##  combine_latest: ---1:4--2:4--3:4--3:5->

