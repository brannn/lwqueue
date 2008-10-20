require 'lwqueue'

queue = LWQueue.new( :server => '127.0.0.1', :queue => 'rubyqueue' )

# Push a simple string
queue.push("This is a test message at #{Time.now}")
puts queue.pop

# Push a hash
queue.push( "x" => "This is a test message at #{Time.now}", "y" => "Another part of the message" )
obj = queue.pop
puts obj['x']
puts obj['y']