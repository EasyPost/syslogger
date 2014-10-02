# SysLogger

Ruby Logger for interacting with syslog using RFC 5424 format.

## Description

`syslogger` is a wrapper around the standard ruby `Logger` for logging via syslog. Messages passed to `syslogger` are formatted by default with [RFC 5424](http://tools.ietf.org/html/rfc5424). It allows for communication through sockets or files.

## Install

```
gem install syslogger5424
```

or add the following line to Gemfile:

```
gem 'syslogger5424'
```

and run `bundle install` from your shell.

## Usage

```ruby
require 'syslogger'

log = SysLogger.new
log.info("Hello\nWorld")
# <190>1 2014-10-02T11:59:52.524177-07:00 HOSTNAME - - - [meta x-group="79748942"] Hello
# <190>1 2014-10-02T11:59:52.524177-07:00 HOSTNAME - - - [meta x-group="79748942"] World
```

When strings containing newlines are logged, lines are seperated and written. These lines are grouped together by the `meta` SD-ID under the `x-group` parameter.

The default `facility` is local7 (23). To change this or any other information in the header, set the logger's formatter after creation.

```ruby
require 'syslogger'

log = SysLogger.new
log.formatter = SysLogger::Formatter::RFC5424.new("APP-NAME", "PROCID", "MSGID", "kern")

log.info("Hello\nWorld")
# <6>1 2014-10-02T12:16:54.222893-07:00 HOSTNAME APP-NAME PROCID MSGID [meta x-group="78784030"] Hello
# <6>1 2014-10-02T12:16:54.222893-07:00 HOSTNAME APP-NAME PROCID MSGID [meta x-group="78784030"] World
```

By default, `SysLogger` will write to `$stdout`. To override, either pass a device to the constructor or a block that can be called to create the device.

```ruby
require 'syslogger'

io = StringIO.new
log = SysLogger.new(io)
log.info("Hello\nWorld")

log = SysLogger.new { UNIXSocket.new('/tmp/sock') }
log.info("Hello\nWorld")
```
