require 'spec_helper'

describe Reactive::Observable do
  include Lets

  context '#each' do

    context 'interval 10' do

      before do
        s = Reactive::Observable.interval(10)
        @passed_values = []
        s.each do |value|
          @passed_values << value
        end
      end

      it do
        advance_by(20)
        @passed_values.should == [0,1]
      end

    end

    context 'raise error' do
      before do
        s = Reactive::Observable.timer(10).push(
          Reactive::Observable.error(Exception)
        )
        s.each do |value|
            value
        end
      end

      it do
        expect {  advance(10) }.to raise_error(Exception)
      end

    end

  end


end