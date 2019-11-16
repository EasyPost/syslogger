0.5.3
-----
- Don't connect on initialization

0.5.2
-----
- Fix a typo in the Unix STREAM-mode socket connector
- Add more tests!

0.5.1
-----
- Add a new API for setting the `appname` and `procid` of the formatter directly from the Logger instance
- Improve the `procid` so that when it's unset it uses the PID at log time instead of logger construction time (to
  better handle pre-fork importing)

0.5.0
-----
- Improve handling of multiline messages
