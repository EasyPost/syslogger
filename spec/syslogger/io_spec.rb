require 'socket'
require 'rspec/temp_dir'

require 'syslogger/creators'

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

  describe "#flush" do
    it "works without writing first" do
      subject.flush
    end

    it "handles array messages" do
      subject.write(["foo", "bar"])
      expect(io.string).to eq "foobar"
    end

    it "works after writing" do
      subject.write('foobar')
      subject.flush
      expect(io.string).to eq "foobar"
    end

    it "works after an exception" do
      expect(io).to receive(:write).at_least(:once).and_raise(IOError.new)
      subject.write('foobar')
      subject.flush
    end
  end

  describe "unix_dgram_socket" do
    let(:socket_path) { "#{temp_dir}/listen.sock"  }
    subject { SysLogger::IO.new(&SysLogger::Creators::unix_dgram_socket(socket_path))  }

    describe "#write integration" do
      include_context "uses temp dir"

      it "actually can write to a domain socket" do
        s = Socket.new(Socket::Constants::AF_LOCAL, Socket::Constants::SOCK_DGRAM, 0)
        s.bind(Socket.pack_sockaddr_un(socket_path))
        subject.write("foobar\n")
        expect(s.recvfrom(1024)[0]).to eq "foobar\n"
      end
    end
  end
end
