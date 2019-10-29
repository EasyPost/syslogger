Gem::Specification.new do |spec|
  spec.name          = "syslogger5424"
  spec.version       = "0.5.0"
  spec.date          = "2016-10-12"
  spec.summary       = "Logging via syslog using RFC 5424 format"
  spec.authors       = ["EasyPost"]
  spec.email         = "support@easypost.com"
  spec.homepage      = "http://github.com/EasyPost/syslogger"

  spec.files         = `git ls-files -- lib/*`.split("\n")
  spec.test_files    = `git ls-files -- spec/*`.split("\n")
  spec.require_paths = ["lib"]

  spec.add_dependency "mono_logger"

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "rspec-its"
  spec.add_development_dependency "rspec-temp_dir"
end
