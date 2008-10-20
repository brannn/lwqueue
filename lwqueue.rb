class LWQueue

  # Only special thing needed is ruby-json gem installed
  # otherwise remove the relevant lines to use Marshal
  # instead of JSON serialization

  require 'socket'
  require 'base64'
  require 'rubygems'
  require_gem 'ruby-json'

  def initialize(args)
    host = args[:server]
    host, port = args[:server].split(':')
    @socket = TCPSocket.new(host, port || 3130)
    @queue = args[:queue]
    @debug = args[:debug]
    ObjectSpace.define_finalizer(self, self.class.method(:finalize).to_proc)
  end
  
  def LWQueue.finalize
    @socket.close
  end

  def push(data)
    if data.class != String && data.class != Fixnum
      #      data = "{{serialized-ruby}}" + Marshal.dump(data)
      data = "{{serialized-json}}" + data.to_json
    end
    @socket.print Base64.encode64("PUSH-#{@queue}-#{data}") + "\n=====\n"
    begin
      answer = @socket.gets
      puts answer if @debug
      return true if answer =~ /OK/i
    rescue
      nil
    end
    return nil
  end
  
  def pop
    @socket.print Base64.encode64("POP-#{@queue}") + "\n=====\n"
    data = ""
    while data += @socket.gets
      break if data =~ /\=\=\=\=\=/
    end
    data = Base64.decode64(data)
    
    if data =~ /^\{\{serialized-json\}\}/
      #      return Marshal.load(data.sub(/^\{\{serialized-ruby\}\}/, ''))
      data = data.sub(/^\{\{serialized-json\}\}/, '')
      data = {}.from_json( JSON::Lexer.new(data) ) 
      return data
    end
    
    return nil if data.length < 2
    return data
  end
  
end

