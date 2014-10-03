Gem::Specification.new do |spec|
  spec.name          = "syslogger5424"
  spec.version       = "0.2.0"
  spec.date          = "2014-09-30"
  spec.summary       = "Logging via syslog"
  spec.authors       = ["EasyPost"]
  spec.email         = "support@easypost.com"
  spec.homepage      = "http://github.com/EasyPost/syslogger"

  spec.files         = `git ls-files -- lib/*`.split("\n")
  spec.test_files    = `git ls-files -- spec/*`.split("\n")
  spec.require_paths = ["lib"]

  spec.add_dependency "mono_logger"

  spec.add_development_dependency "rspec"
  spec.add_development_dependency "rspec-its"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "pry-nav"
end
