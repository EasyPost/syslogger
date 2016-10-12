require "mono_logger"

module SysLogger
  class Logger < MonoLogger
    attr_reader :logdev, :default_formatter

    def initialize(logdev = nil, shift_age = 0, shift_size = 1048576, &block)
      if logdev.nil? && block_given?
        super(SysLogger::IO.new(&block), shift_age, shift_size)
      elsif logdev.nil?
        super($stdout, shift_age, shift_size)
      else
        super(logdev, shift_age, shift_size)
      end

      @default_formatter = SysLogger::Formatter::RFC5424.new
    end

    def <<(msg)
      # Logger's version of this just dumps the input without formatting. there
      # is never a case where we don't want to format the content to the syslog
      # server properly.
      # default to a serverity of info.
      msg.split(/\r?\n/).each { |line|
          if line then
              self.info(line)
          end
      }
    end

    alias_method :write, :<<
  end
end
