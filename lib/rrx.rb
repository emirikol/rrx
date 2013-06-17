require "reactive/version"
require 'weakref'
require 'pp'
require 'active_support'
require 'eventmachine'

require 'active_support/core_ext/module/delegation'
require 'active_support/core_ext/module/introspection'
require 'active_support/core_ext/class/attribute'

module Reactive

  autoload :Observer, 'reactive/observer'
  autoload :Scheduler, 'reactive/scheduler'
  autoload :Observable, 'reactive/observable'

  class AmbivalentRef < WeakRef

    def self.create(value)
      case value
        when NilClass, TrueClass, FalseClass, Fixnum, Symbol
          value
        else
          new(value)
      end
    end

    def __getobj__
      super rescue nil
    end
  end

  module Disposable
    class Wrapper
      attr_reader :target

      def initialize(target = nil, parent = nil)
        @parent = AmbivalentRef.create(parent)
        self.target = target
      end

      def target=(v)
        @target = AmbivalentRef.create(v)
      end

      def unwrap
        self.target = nil #return previous target?
      end

    end

    class Closure
      def initialize(&cleanup)
        ObjectSpace.define_finalizer(self, cleanup)
      end
    end
  end


  class ObserverWrapper
    attr_reader :observer, :parent

    def initialize(observer, parent, opts = {})
      attributes.each do |name, default|
        instance_variable_set(:"@#{name}", opts[name])
      end
      @observer =  observer
      @parent =  AmbivalentRef.new(parent)
    end

    def attributes
      self.class.parent.attributes
    end

    def on_next(value)
      @observer.on_next(value)
    end

    def on_complete
      @observer.on_complete
      unwrap
    end

    def wrap_with_parent(child)
      @parent.target = child
    end

    def unwrap
      attributes.each {|name, default|  instance_variable_set(:"@#{name}", nil)  }
      @observer = EmptyObserver.new
      unwrap_parent if active?
    end

    def active?
      @parent
    end

    def unwrap_parent(*args)
      @parent.unwrap(*args)
    end
  end

  #class ReplaySubject
  #
  #
  #  def subject
  #    @subject ||= Subject.new
  #  end
  #
  #  def run(observer)
  #    wrapper = subject.run(observer)
  #    @queue.each {|q| q.accept(observer) }
  #    return wrapper
  #  end
  #
  #  def on_next(value)
  #    @queue << value
  #    value.accept(subject)
  #  end
  #
  #end


end

