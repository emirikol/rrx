require 'spec_helper'

describe Reactive::Observable do

  include Lets

  context '#count from interval(1000)' do
    before do
      @s = Reactive::Observable.interval(1000).count
      @s.subscribe(observer)
    end

    advance_by(1001) do
      should send_call.with(1).on(observer, :on_next)
    end

    advance_by(2001) do
      should send_call.with(2).on(observer, :on_next)
    end

    advance_by 7001 do
      should send_call.with(7).on(observer, :on_next)
    end

  end

end