require 'spec_helper'

describe Reactive::Observable do
  include Lets

  context '#skip(3) on list(4..0)' do

    before do
      @s = Reactive::Observable.from_array([4,3,2,1,0]).skip(3)
    end

    #TODO send_call..with should accept arguments for each time. in this case 1, 0
    advance_by(0).and do |expectation|
      expectation.next_should { be_called.exactly(2).times.with(kind_of(Fixnum)) }
      expectation.complete_should { be_called }
    end

    after do
      @s.subscribe(observer)
    end


  end


end