describe SysLogger::Formatter::RFC5424 do
  its(:msgid)    { is_expected.to eq "-" }
  its(:procid)   { is_expected.to eq "-" }
  its(:appname)  { is_expected.to eq "-" }
  its(:facility) { is_expected.to eq 23 }

  describe "#call" do
    it "generates Format" do
      expect(subject.call(::Logger::INFO, DateTime.now, "Prog", "Message")).
        to match /<190>1.* - - Prog \[meta x-group=".*"\] Message/
    end
  end
end
