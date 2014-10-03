require "syslogger/logger"
require "syslogger/io"
require "syslogger/formatter/rfc5424"

module SysLogger
  extend self

  def new(logdev = nil, shift_age = 0, shift_size = 1048576, &block)
    return Logger.new(logdev, shift_age, shift_size, &block)
  end
end
