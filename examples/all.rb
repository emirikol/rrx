require 'rubygems'
require 'rrx'

 Reactive::Observable.
     once(3).
     merge(
      Reactive::Observable.once(4)
     ).
     subscribe(
      :on_next => lambda {|v| puts "on_next = #{v}"  },
      :on_complete => lambda { puts "done"  }
     )

EventMachine.run do

  Reactive::Observable.interval(100).
      map {|x| x * 2 }.
      grep(lambda {|x| x % 3 == 0  }).
      first(10).
      push( Reactive::Observable.once("Bye!")  ).
      subscribe(
        :on_next => lambda {|v|  puts "#{v}" },
        :on_complete => lambda { puts "done ticking" }
      )


 Reactive::Observable.interval(1000).
 merge(
   Reactive::Observable.interval(500)
 ).
 subscribe(
     :on_next => lambda {|v| puts "tick #{v}" },
     :on_complete => lambda { puts "done ticking"; EventMachine.stop_event_loop }
 )

end