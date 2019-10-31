require 'date'


describe SysLogger::Formatter::RFC5424 do
  its(:msgid)    { is_expected.to eq "-" }
  its(:procid)   { is_expected.to eq nil }
  its(:appname)  { is_expected.to eq nil }
  its(:facility) { is_expected.to eq 23 }

  let(:test_date) { DateTime.new(2019, 10, 31, 20, 8) }
  let(:test_hostname) { "host1sf" }

  before do
    allow(Socket).to receive(:gethostname).and_return(test_hostname)
  end

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

    context "nil appname" do
      it "formats correctly" do
        expect(Socket).to receive(:gethostname).and_return(test_hostname)
        expect(subject).to receive(:gen_xgroup).and_return(74901736)
        expect(subject.call(::Logger::INFO, test_date, "Prog", "Message")).to eq (
          "<190>1 2019-10-31T20:08:00.000000+00:00 host1sf - #{Process.pid.to_s} Prog [meta x-group=\"74901736\" x-counter=\"1\"] Message\n"
        )
      end
    end

    context "custom appname" do
      it "formats correctly" do
        subject.appname = "short-appname"
        expect(subject).to receive(:gen_xgroup).and_return(74901736)
        expect(subject.call(::Logger::INFO, test_date, "Prog", "Message")).to eq (
          "<190>1 2019-10-31T20:08:00.000000+00:00 host1sf short-appname #{Process.pid.to_s} Prog [meta x-group=\"74901736\" x-counter=\"1\"] Message\n"
        )
      end

      it "truncates to 48 bytes" do
        subject.appname = "this-is-a-very-long-appname-with-many-parts-in-it-for-sure-yep"
        expect(subject).to receive(:gen_xgroup).and_return(74901736)
        expect(subject.call(::Logger::INFO, test_date, "Prog", "Message")).to eq (
          "<190>1 2019-10-31T20:08:00.000000+00:00 host1sf this-is-a-very-long-appname-with-many-parts-in-it #{Process.pid.to_s} Prog [meta x-group=\"74901736\" x-counter=\"1\"] Message\n"
        )
      end
    end
  end
end
