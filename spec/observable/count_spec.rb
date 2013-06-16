require 'spec_helper'

describe Reactive::Observable::Count do

  include Lets

  context '#count from interval(1000)' do
    before do
      @s = Reactive::Observable.interval(1000).count
      @s.subscribe(observer)
    end

    it 'fires with 1 after one interval' do
      observer[:on_next].should_receive(:call).with(1)
      advance_by(1001)
    end

    it 'fires with 2 after two intervals' do
      observer[:on_next].should_receive(:call).with(2)
      advance_by 2001
    end

    it 'fires with 7 after 7 intervals' do
      observer[:on_next].should_receive(:call).with(7)
      advance_by 7001
    end

  end

end