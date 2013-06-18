require 'spec_helper'

describe Reactive::Observable::Merge do
  include Lets

  context 'merge timer(20), timer(30) and interval(16)' do

    before do
      @s = Reactive::Observable.timer(20).merge(
             Reactive::Observable.timer(30)
           ).merge(
             Reactive::Observable.interval(16)
           )
      @s.subscribe(observer)
    end

    advance_by(10) do
      observer[:on_next].should_not_receive(:call)
    end

    advance_by(16) do
      should send_call.with(0).to(observer, :on_next)
    end

    advance_by(20) do
      should send_call.exactly(:twice).with(kind_of(Fixnum)).to(observer, :on_next)
    end

    advance_by(30) do
      should send_call.exactly(3).times.with(kind_of(Fixnum)).to(observer, :on_next)
    end

    advance_by(30) do
      should send_call.exactly(3).times.with(kind_of(Fixnum)).to(observer, :on_next)
    end

    advance_by(32) do
      should send_call.exactly(4).times.with(kind_of(Fixnum)).to(observer, :on_next)
    end

  end

  context 'all merged observables complete' do
    before do
      @s = Reactive::Observable.timer(20).merge(Reactive::Observable.timer(10))
      @s.subscribe(observer)
    end
    advance_by(20).and do |its|
      its.next_should { be_called.exactly(2).times.with(0)  }
      its.complete_should { be_called }
    end

  end

  context 'error on merged' do
    before do
      @s = Reactive::Observable.interval(10).merge(
          Reactive::Observable.timer(15).push(
              Reactive::Observable.error('an error')
          )
      )
      @s.subscribe(observer)
    end

    advance_by(10).and do |its|
      its.next_should { be_called.with(0) }
    end

    advance_by(15).and do |its|
      its.next_should { be_called.exactly(:twice).with(0) }
      its.error_should { be_called.with('an error') }
    end

    advance_by(40).and do |its|
      its.next_should { be_called.exactly(:twice).with(0) }
      its.error_should { be_called.with('an error')  }
    end

  end

  context 'immidiate observables' do
    before do
      @s = Reactive::Observable.once(1)
    end

    context 'only' do
      before do
        @s = @s.merge( Reactive::Observable.once(2) )
      end
      advance_by(0).and do |its|
        its.next {
          should send_call.with(1).to(observer, :on_next).ordered
          should send_call.with(2).to(observer, :on_next).ordered
        }
        its.complete_should {  be_called }
      end
      after do
        @s.subscribe(observer)
      end
    end

    #TODO fix.
    context 'mixed' do
      before do
        @s = @s.merge( Reactive::Observable.timer(100) )
      end
      context 'grrr' do
        before do
          observer[:on_next].should_receive(:call).with(1).ordered
          observer[:on_complete] = ->() {}
        end
        it {
          should send_call.with(1).ordered
        }
        after do
          @s.subscribe(observer)
        end
      end
      context 'grr' do
        before do
          observer[:on_next] = ->(v) {}
          @s.subscribe(observer)
        end
        advance_by(100).and do |its|
          its.complete_should { be_called }
        end
      end

    end

  end

  context 'on observable of observables' do
    before do
      @s = Reactive::Observable.from_array([
        Reactive::Observable.once(1),
        Reactive::Observable.once(2),
        Reactive::Observable.once(4)
      ]).merge
    end

    advance_by(0).and do |its|
      its.next {
        [1,2,4].each do |i|
          should send_call.with(i).to(observer, :on_next)
        end
      }
      its.complete_should { be_called }
    end

    after do
      @s.subscribe(observer)
    end

  end

  context 'as class method' do
    before do
      Reactive::Observable.merge(
        Reactive::Observable.timer(100),
        Reactive::Observable.timer(200),
        Reactive::Observable.timer(150)
      ).subscribe(observer)
    end

    advance_by(301).and do |its|
      #its.next {
      #  [1,2,4].each do |i|
      #    should send_call.with(i).to(observer, :on_next)
      #  end
      #}
      its.next_should { be_called.exactly(3).times.with(kind_of(Fixnum)) }
      its.complete_should { be_called }
    end


  end

end