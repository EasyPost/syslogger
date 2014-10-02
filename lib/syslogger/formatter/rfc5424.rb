module SysLogger
  module Formatter
    class RFC5424 < ::Logger::Formatter
      attr_reader :msgid, :procid, :appname

      Format = "<%s>1 %s %s %s %s %s [meta x-group=\"%s\"] %s\n"

      FACILITIES = {
        :kern     => 0,
        :user     => 1,
        :mail     => 2,
        :daemon   => 3,
        :auth     => 4,
        :syslog   => 5,
        :lpr      => 6,
        :news     => 7,
        :uucp     => 8,
        :cron     => 9,
        :authpriv => 10,
        :ftp      => 11,
        :ntp      => 12,
        :audit    => 13,
        :alert    => 14,
        :at       => 15,
        :local0   => 16,
        :local1   => 17,
        :local2   => 18,
        :local3   => 19,
        :local4   => 20,
        :local5   => 21,
        :local6   => 22,
        :local7   => 23
      }

      SEVERITIES = {
        :emerg  => 0,
        :alert  => 1,
        :crit   => 2,
        :fatal  => 2,
        :err    => 3,
        :error  => 3,
        :warn   => 4,
        :notice => 5,
        :info   => 6,
        :debug  => 7
      }

      def initialize(appname = nil, procid = nil, msgid = nil, facility = nil)
        super()

        @msgid = format(msgid, 32)
        @procid = format(procid, 128)
        @appname = format(appname, 48)
        @facility = facility || FACILITIES[:local7]
      end

      def facility; @facility; end
      def facility=(f)
        @facility = FACILITIES[f.to_s.downcase.to_sym] || @facility
      end

      def call(severity, datetime, progname, message)
        severity = SEVERITIES[severity.to_s.downcase.to_sym] || SEVERITIES[:info]
        pri = (facility * 8) + severity

        # Since we're using RFC5424 format, it makes more sense to use the
        # passed in progname as the msgid rather than changing the appname when
        # a block was received to generate the message.
        message_id = progname.nil? ? msgid : format(progname, 32)

        x_group = rand(99999999)
        lines = msg2str(message).split(/\r?\n/).reject(&:empty?).map do |line|
          Format % [pri, datetime.strftime("%FT%T.%6N%:z"), Socket.gethostname,
                    appname, procid, message_id, x_group, line]
        end

        lines.join
      end

      def format(text, max_length)
        if text
          text[0..max_length].gsub(/\s+/, '')
        else
          '-'
        end
      end
    end
  end
end
