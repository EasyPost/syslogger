require 'socket'
require 'logger'

class SysLogger < Logger
  def initialize(socket_creator=nil)
    super(SyslogRFC5424.new(socket_creator))
    # the formatter is set on the Logger object, so proxy that to the logdev
    @formatter = proc { |*a| @logdev.dev.call(*a) }
  end

  def <<(msg)
    # Logger's version of this just dumps the input without formatting. there
    # is never a case where we don't want to format the content to the syslog
    # server properly.
    # default to a serverity of info.
    msg.split(/\r?\n/).each { |line| self.info(line) if line }
  end

  # make this logger work with rack
  # https://github.com/rack/rack/issues/412
  alias_method :write, :<<
  alias_method :puts, :<<

  def flush
    @logdev.dev.flush()
  end

  # these fields need to be set on the IO-like object, so proxy the calls
  # to the logdevice Logger keeps
  def sdata(*a)
    @logdev.dev.sdata(*a)
  end

  def facility
    @logdev.dev.facility
  end
  def facility=(f)
    @logdev.dev.facility = f
  end

  def appname
    @logdev.dev.appname
  end
  def appname=(a)
    @logdev.dev.appname = a
  end

  def procid
    @logdev.dev.procid
  end
  def procid=(p)
    @logdev.dev.procid = p
  end

  def msgid;
    @logdev.dev.msgid
  end
  def msgid=(m)
    @logdev.dev.msgid = m
  end

  class SyslogRFC5424 < Logger::Formatter
    FACILITIES = {
      :kern      => 0,
      :user      => 1,
      :mail      => 2,
      :daemon    => 3,
      :auth      => 4,
      :syslog    => 5,
      :lpr       => 6,
      :news      => 7,
      :uucp      => 8,
      :cron      => 9,
      :authpriv  => 10,
      :ftp       => 11,
      :ntp       => 12,
      :audit     => 13,
      :alert     => 14,
      :at        => 15,
      :local0    => 16,
      :local1    => 17,
      :local2    => 18,
      :local3    => 19,
      :local4    => 20,
      :local5    => 21,
      :local6    => 22,
      :local7    => 23
    }

    # the duplicates here are to map the Logger severity level names to
    # syslog severity values
    SEVERITIES = {
      :emerg    => 0,
      :alert    => 1,
      :crit     => 2,
      :fatal    => 2,
      :err      => 3,
      :error    => 3,
      :warn     => 4,
      :notice   => 5,
      :info     => 6,
      :debug    => 7
    }

    def initialize(socket_creator=nil)
      @hostname = Socket.gethostname
      @appname = "-"
      @procid = "-"
      @msgid = "-"
      @facility = FACILITIES[:local7]
      @sdata = {}
      @sdata_s = '-'
      @socket_creator = socket_creator
    end

    def call(severity, datetime, progname, msg)
      severity = SEVERITIES[severity.to_s.downcase.to_sym] || SEVERITIES[:info]
      pri = (@facility * 8) + severity
      now = datetime.strftime("%FT%T.%6N%:z")
      appname = _fixup_field(@appname.respond_to?(:call) ? @appname.call : @appname, 48)
      procid = _fixup_field(@procid.respond_to?(:call) ? @procid.call : @procid, 128)
      # since we're using RFC5424 format, it makes more sense to use the
      # passed in progname as the msgid rather than changing the appname
      # when a block was received to generate the message
      if progname
        msgid = _fixup_field(progname, 32) if progname
      else
        msgid = _fixup_field(@msgid.respond_to?(:call) ? @msgid.call : @msgid, 32)
      end
      dofo = proc { |msg| "<#{pri}>1 #{now} #{@hostname} #{appname} #{procid} #{msgid} #{@sdata_s} #{msg}\n" }
      msg = msg2str(msg).split(/\n/)
      if msg.length == 1
        dofo.call(msg.shift)
      else
        a = []
        sdata(:meta, "x-group", rand(99999999))
        msg.each { |msg| a.push(dofo.call(msg)) }
        sdata(:meta, "x-group")
        a
      end
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

    def facility=(f)
      @facility = FACILITIES[f.to_s.downcase.to_sym] || FACILITIES[:local7]
    end

    def sdata(id, name, value=nil)
      if value == nil
        @sdata[id].delete(name)
        if @sdata[id].empty?
          @sdata.delete(id)
        end
      else
        if @sdata.key?(id)
          @sdata[id][name] = value
        else
          @sdata[id] = {name=>value}
        end
      end
      format_sdata
    end

    def format_sdata
      if @sdata.empty?
        @sdata_s = '-'
        return
      end
      # TODO clean up of SD-NAMe and PARAM-VALUE is kind of brute force
      #      here, could be done better per RFC5424
      r = []
      @sdata.each { |sid, hash|
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
      @sdata_s = r.join("")
    end

    def _fixup_field(m, size)
      m = m.to_s
      m = m[0..size].gsub(/\s+/, '')
      m = "-" if m.empty?
      m
    end

    def appname=(a)
      @appname = a
    end

    def procid=(p)
      @procid = p
    end

    def msgid=(m)
      @msgid = m
    end

    def create_socket
      if @socket_creator
          @socket = @socket_creator.call()
      else
          @socket = $stdout
      end
    end

    def transmit(message)
      if message.is_a?(Array)
        message.each { |x| transmit(x) }
      else
        begin
          tries ||= 2
          if @socket == nil || @socket.closed?
            create_socket
          end
          begin
            @socket.send(message, 0)
          rescue
            # we might not be writing to an IO that accepts send()
            # but we want to use send by default so we get the proper
            # framing of the messages for datagram protocol
            @socket.write(message)
          end
        rescue
          @socket.close
          create_socket
          retry unless (tries -= 1).zero?
        end
      end
    end

    alias_method :write, :transmit
    alias_method :puts, :transmit

    def flush
      @socket.flush
    end

    def close
      @socket.close
    end
  end
end
