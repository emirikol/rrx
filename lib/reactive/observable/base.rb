module Reactive::Observable

  class Base

    class_attribute :attributes
    self.attributes = []

    def self.add_attributes(*v)
      defaults = v.last.kind_of?(Hash) ? v.pop.to_a : []
      v.map! {|x| [x,nil] }
      self.attributes += v + defaults
    end

    def self.observer_on_next(&method)
      observer = Class.new(Reactive::ObserverWrapper) do
        define_method(:on_next, &method)
      end
      const_set(:Observer, observer)
    end
    def self.observer_on_complete(&method)
      observer = Class.new(Reactive::ObserverWrapper) do
        define_method(:on_complete, &method)
      end
      const_set(:Observer, observer)
    end

    delegate :schedule_periodic, :schedule_once, :now, to: :scheduler


    def initialize(opts = {})
      self.class.attributes.each { |name, default|
        instance_variable_set(:"@#{name}", opts[name] || default)
      }
    end

    def observer_args(observer, parent)
      #base = {:observer => observer, :parent => parent}
      opts = self.class.attributes.each_with_object({}) do |attr, hash|
        hash[attr[0]] = instance_variable_get(:"@#{attr[0]}")
      end
      [observer, parent, opts]
    end

    def scheduler
      @scheduler ||= Reactive::Scheduler.new
    end

    def subscribe(handlers)
      [:on_next, :on_error, :on_complete].each {|h| handlers[h] ||= ->(*v) { }  }
      observer = Reactive::Observer.new(handlers)
      #???
      self.subscribe_observer(observer)
    end

    def subscribe_observer(observer)
      self.run(observer)
    end

    ##!!!
    def maybe_scheduler(arg = nil)
      arg ? {scheduler => arg} : {}
    end

    def each
      subscribe(
          :on_next => ->(value) {  yield value },
          :on_error => ->(error) {  raise error }
      )
    end

    #joining

    def count
      Count.new(target: self)
    end

    def each_slice(count, options = {})
      EachSlice.new(target: self, count: count, skip: options[:skip] || 0)
    end

    def merge(observable = nil)
      #MultiMerge.new(observables)
      #observable = observables[0]
      observable ?
          Merge.new(o1: self, o2: observable) :
          MergeNotifications.new(target: self)
    end

    def combine_latest(observable)
      CombineLatest.new(o1: self, o2: observable)
    end

    def map(&proc)
      Map.new(target: self, mapper: proc)
    end

    def grep(predicate)
      Grep.new(target: self, predicate: predicate)
    end

    def first(count = 1)
      First.new(target: self, count: count)
    end

    def push(observable)
      Push.new(target: self, o2: observable)
    end

    def skip(count)
      Skip.new(target: self, count: count)
    end

    def unshift(*values)
      if values.size == 1 && values[0].kind_of?(Base)
        observable = values[0]
      else
        observable = Reactive::Observable.from_array(values)
      end
      Unshift.new(target: self, unshifted: observable)
    end

  end

end