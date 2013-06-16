require 'spec_helper'

describe Reactive::Observable do
  include Lets

  context '#interval(400)' do

    before do
      @s = Reactive::Observable.interval(400)
      @s.subscribe(observer)
    end

    it "does not fire on subscribe" do
      observer[:on_next].should_not_receive(:call)
    end

    it "does not fire before interval has passed" do
      scheduler.advance_by(200)
    end

    it "fires once interval was reached" do
      observer[:on_next].should_receive(:call).with(0)
      scheduler.advance_by(400)
    end

    it "fires for each interval passed" do
      [0,1,2,3].each do |i|
        observer[:on_next].should_receive(:call).times.with(i).ordered
      end
      scheduler.advance_by(1600)
    end

    context "when it has been destroyed" do
      #didn't manage to garbage collect without using before block.
      before do
        remove_instance_variable(:@s)
        ObjectSpace.garbage_collect
      end
      it 'does not fire' do
        scheduler.advance_by(400)
      end
    end

  end


end
