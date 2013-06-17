require 'spec_helper'

describe Reactive::Observable::Base do
  include Lets

  context '#unshift' do

    context 'empty subscription' do
      before {
        @s = Reactive::Observable.from_array([1,2,4,8]).unshift(
            Reactive::Observable.once( 0 )
        )
      }
      advance_by(0).and do |its|
        its.next_should {  be_called.exactly(5).times.with(kind_of(Fixnum))  }
        its.complete_should { be_called }
      end
      after {
        @s.subscribe(observer)
      }
    end

    it 'creates array observable from multiple args' do
      @s = Reactive::Observable.once( 0 ).unshift(1, 2)

      @s.should send_call.with(no_args).to(observer, :on_complete)
      @s.should send_call.with(1).to(observer, :on_next).ordered
      @s.should send_call.with(2).to(observer, :on_next).ordered
      @s.should send_call.with(0).to(observer, :on_next).ordered
      @s.subscribe(observer)
    end



  end

end