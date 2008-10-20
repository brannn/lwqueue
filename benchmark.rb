require 'lwqueue'
require 'benchmark'

queue = LWQueue.new( :server => '127.0.0.1', :queue => 'c' )

puts Benchmark.measure { 
  100.times { |i|
    queue.push("hello people #{i}")
  }
}.inspect

puts Benchmark.measure {
  100.times {
    x = queue.pop
    puts x
  }
}.inspect