require 'spec_helper'

describe Reactive::Observable do

  include Lets

  context '#count from interval(1000)' do
    before do
      @s = Reactive::Observable.interval(1000).count
      @s.subscribe(observer)
    end

    context 'first interval' do
      advance_by(1000) do
        should send_call.with(1).on(observer, :on_next)
      end
    end

    context 'seven intervals' do
      advance_by(7000) do
        1.upto(7).each do |i|
          should send_call.with(i).on(observer, :on_next).ordered
        end
      end
    end

  end

end