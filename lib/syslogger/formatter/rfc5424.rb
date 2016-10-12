module SysLogger
  module Formatter
    class RFC5424 < ::Logger::Formatter
      attr_reader :msgid, :procid, :appname

      Format = "<%s>1 %s %s %s %s %s %s %s\n"

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

        @counter = 0

        @hostname = Socket.gethostname
        @msgid = format_field(msgid, 32)
        @procid = procid
        @procid = format_field(procid || Process.pid.to_s, 128)
        @appname = format_field(appname, 48)

        self.facility = facility || :local7
      end

      def facility
        @facility
      end

      def facility=(f)
        @facility = FACILITIES[f.to_s.downcase.to_sym] || @facility
      end

      def call(severity, datetime, progname, message)
        severity = SEVERITIES[severity.to_s.downcase.to_sym] || SEVERITIES[:info]
        pri = (facility << 3) | severity

        # Since we're using RFC5424 format, it makes more sense to use the
        # passed in progname as the msgid rather than changing the appname when
        # a block was received to generate the message.
        message_id = progname.nil? ? msgid : format_field(progname, 32)

        @counter = (@counter + 1) % 65536

        structured_data = {
          "meta" => {
            "x-group" => rand(99999999),
            "x-counter" => @counter
          }
        }

        sd = format_sdata(structured_data)

        lines = msg2str(message).split(/\r?\n/).reject(&:empty?).map do |line|
          Format % [pri, datetime.strftime("%FT%T.%6N%:z"), @hostname,
                    @appname, format_field(@procid || Process.pid.to_s, 128),
                    message_id, sd, line]
        end

        lines.join
      end

      private
      def format_field(text, max_length)
        if text
          text[0..max_length].gsub(/\s+/, '')
        else
          '-'
        end
      end

      def format_sdata(sdata)
        if sdata.empty?
          '-'
        end
        # TODO clean up of SD-NAMe and PARAM-VALUE is kind of brute force
        #      here, could be done better per RFC5424
        r = []
        sdata.each { |sid, hash|
          s = []
          s.push(sid.to_s.gsub(/[^-\w]/, ""))
          hash.each { |n, v|
            paramname = n.to_s.gsub(/[^-\w]/, "")
            paramvalue = v.to_s.gsub(/[\]"=]/, "")
            s.push("#{paramname}=\"#{paramvalue}\"")
          }
          r.push("["+s.join(" ")+"]")
        }
        rx = []
        r.each { |x|
          rx.push("[#{x}]")
        }
        r.join("")
      end

      def msg2str(msg)
        case msg
          when ::String
            msg
          when ::Exception
            "#{ msg.message } (#{ msg.class })\n" <<
              (msg.backtrace || []).join("\n")
          else
            msg.inspect
        end
      end
    end
  end
end
