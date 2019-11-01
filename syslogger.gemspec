Gem::Specification.new do |spec|
  spec.name          = "syslogger5424"
  spec.version       = "0.5.1"
  spec.date          = "2019-11-01"
  spec.summary       = "Logging via syslog using RFC 5424 format"
  spec.description   = "Logger subclass to log to syslog using the RFC 5424 format, with support for STREAM- and DGRAM-mode domain sockets"
  spec.authors       = ["EasyPost"]
  spec.email         = "oss@easypost.com"
  spec.homepage      = "http://github.com/EasyPost/syslogger"
  spec.metadata["changelog_uri"] = "https://github.com/easypost/syslogger/blob/master/CHANGES.md"
  spec.license       = "ISC"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.1")

  spec.files         = `git ls-files -- lib/*`.split("\n")
  spec.test_files    = `git ls-files -- spec/*`.split("\n")
  spec.require_paths = ["lib"]

  spec.add_dependency "mono_logger", "~> 1.0"

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "rspec-its"
  spec.add_development_dependency "rspec-temp_dir"
end
