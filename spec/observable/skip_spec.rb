require 'spec_helper'

describe Reactive::Observable do
  include Lets

  context '#skip(3) on list(4..0)' do

    before do
      @s = Reactive::Observable.from_array([4,3,2,1,0]).skip(3)
    end

    #TODO send_call..with should accept arguments for each time. in this case 1, 0
    it {
      observer[:on_complete] = ->() {}
      should send_call.exactly(2).times.with(kind_of(Fixnum)).to(observer, :on_next)
    }
    it {
      observer[:on_next] = ->(v) {}
      should send_call.with(no_args).to(observer, :on_complete)
    }

    after do
      @s.subscribe(observer)
    end


  end


end