describe SysLogger::Logger do
  let(:io) { StringIO.new }

  subject { SysLogger::Logger.new(io) }

  its("logdev.dev")       { is_expected.to be io }
  its(:default_formatter) { is_expected.to be_a SysLogger::Formatter::RFC5424 }

  it "logs exceptions" do
    subject.error StandardError.new("foobar")
    expect(io.string).to match(
      /<187>1.* - - - \[meta x-group=".*"\] foobar \(StandardError\)/)
  end
end
