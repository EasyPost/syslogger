require 'date'


describe SysLogger::Formatter::RFC5424 do
  its(:msgid)    { is_expected.to eq "-" }
  its(:procid)   { is_expected.to eq Process.pid.to_s }
  its(:appname)  { is_expected.to eq "-" }
  its(:facility) { is_expected.to eq 23 }

  describe "#call" do
    it "generates Format" do
      expect(subject.call(::Logger::INFO, DateTime.now, "Prog", "Message")).
        to match(/<190>1.* - #{Process.pid} Prog \[meta x-group="[^"]+" x-counter="[^"]+"\] Message/)
    end

    it "counts sequentially" do
      line1 = subject.call(::Logger::INFO, DateTime.now, "Prog", "Message1")
      if line1 =~ /.*x-counter="([^"]+)".*/
        counter1 = $1.to_i
      else
        counter1 = 0
      end
      line2 = subject.call(::Logger::INFO, DateTime.now, "Prog", "Message2")
      if line2 =~ /.*x-counter="([^"]+)".*/
        counter2 = $1.to_i
      else
        counter2 = 0
      end
      expect(counter2).to be > counter1
    end
  end
end
