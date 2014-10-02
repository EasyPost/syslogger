describe SysLogger::IO do
  let(:io) { StringIO.new }

  subject { SysLogger::IO.new { io } }

  its(:file) { is_expected.to eq io }

  describe "#write" do
    it "uses io" do
      subject.write("foobar")
      expect(io.string).to eq "foobar"
    end
  end
end
