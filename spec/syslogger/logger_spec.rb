describe SysLogger::Logger do
  let(:io) { StringIO.new }
  let(:time_under_test) { Time.new(2019, 10, 28, 12, 26, 0, "-07:00") }

  subject { SysLogger::Logger.new(io) }

  its("logdev.dev")       { is_expected.to be io }
  its(:default_formatter) { is_expected.to be_a SysLogger::Formatter::RFC5424 }

  before(:example) do
    allow(Time).to receive(:now).and_return(time_under_test)
    allow(Socket).to receive(:gethostname).and_return("testhostname")
    allow(Process).to receive(:pid).and_return(1234)
    allow_any_instance_of(SysLogger::Formatter::RFC5424).to receive(:gen_xgroup).and_return(98765)
  end

  it "logs exceptions" do
    subject.error StandardError.new("foobar")
    expect(io.string).to match(
      /<187>1.* - #{Process.pid} - \[meta x-group=".*"\] foobar \(StandardError\)/)
  end

  it "sends multiline messages as an array" do
    expect(io).to receive(:write).with([
      "<190>1 2019-10-28T12:26:00.000000-07:00 testhostname - 1234 - [meta x-group=\"98765\" x-counter=\"1\"] foo\n",
      "<190>1 2019-10-28T12:26:00.000000-07:00 testhostname - 1234 - [meta x-group=\"98765\" x-counter=\"2\"] bar\n",
      "<190>1 2019-10-28T12:26:00.000000-07:00 testhostname - 1234 - [meta x-group=\"98765\" x-counter=\"3\"] baz\n"
    ])
    subject.info "foo\nbar\nbaz"
  end
end
