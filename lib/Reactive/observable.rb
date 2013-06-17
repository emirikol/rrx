module Reactive
module Observable
  autoload :Composite, 'reactive/observable/composite'
  autoload :DoubleWrapper, 'reactive/observable/double_wrapper'
  autoload :FromProc, 'reactive/observable/from_proc'
  autoload :Generate, 'reactive/observable/generate'
  autoload :Merge, 'reactive/observable/merge'
  autoload :Wrapper, 'reactive/observable/wrapper'
  autoload :Map, 'reactive/observable/map'
  autoload :Grep, 'reactive/observable/grep'
  autoload :First, 'reactive/observable/first'
  autoload :Push, 'reactive/observable/push'
  autoload :Skip, 'reactive/observable/skip'
  autoload :Unshift, 'reactive/observable/unshift'
  autoload :Count, 'reactive/observable/count'
  autoload :Base, 'reactive/observable/base'


  # creation

  def self.once(value)
    FromProc.new do |observer|
      observer.on_next(value)
      observer.on_complete
      Disposable::Wrapper.new
    end
  end

  def self.range(from, size)
    FromProc.new do |observer|
      from.upto(from + size) {|i| observer.on_next(i) }
      observer.on_complete
      Disposable::Wrapper.new
    end
  end

  # from time
  def self.interval(duration)
    Generate.new(
        0,
        lambda {|x| true },
        lambda {|x| 1 + x },
        lambda {|x| x },
        lambda {|x| duration }
    )
  end

  def self.timer(duration)
    Generate.new(
        0,
        lambda {|x| false },
        lambda {|x| x },
        lambda {|x| x },
        lambda {|x| duration }
    )
  end

  def self.from_array(array)
    FromProc.new do |observer|
      array.each { |v|
        observer.on_next(v)
      }
      observer.on_complete
      Disposable::Wrapper.new
    end
  end


end
end