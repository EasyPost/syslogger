module SysLogger
  class IO
    def initialize(&file_creator)
      @file_creator = file_creator
      @file = nil
      @connect_pid = Process.pid
    end

    def file
      # re-connect on fork
      if Process.pid != @connect_pid
        @file.close
      end
      if @file.nil? || @file.closed?
        @file = @file_creator.call
      end
      @file
    end

    def write(message)
      tries = 2
      Array(message).each do |msg|
        begin
          transmit(msg)
        rescue
          file.close
          retry unless (tries -= 1).zero?
        end
      end
    end

    def transmit(message)
      # UNIXSocket overwrites Object#send, so using file.respond_to?(:send)
      # does not work. If send and __send__ have different signigutres call
      # send. Otherwise, call write.
      unless file.method(:send).hash == file.method(:__send__).hash
        file.send(message, 0)
      else
        file.write(message)
      end
    end

    def flush
      if !@file.nil?
        @file.flush
      end
    end

    def close
      if !@file.nil?
        @file.close
        @file = nil
      end
    end
  end
end
