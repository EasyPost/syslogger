module SysLogger
  class Logger < ::Logger
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
  end
end
