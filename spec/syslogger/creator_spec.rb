require 'socket'
require 'rspec/temp_dir'

require 'syslogger/creators'

describe SysLogger::Creators do
  include_context "uses temp dir"

  describe "#unix_datagram_socket" do
    it 'connects' do
      path = (Pathname(temp_dir) + 'datagram.sock').to_s
      listen_sock = Socket.new(Socket::Constants::AF_LOCAL, Socket::Constants::SOCK_DGRAM, 0)
      listen_sock.bind(Addrinfo.unix(path))
      thunk = SysLogger::Creators.unix_dgram_socket(path)
      client_sock = thunk.call
      client_sock.send "foo", 0
      expect(listen_sock.recv(3)).to eq "foo"
    end
  end

  describe "#unix_stream_socket" do
    it 'connects' do
      startup_barrier = Queue.new
      path = (Pathname(temp_dir) + 'stream.sock').to_s
      queue = Queue.new
      t = Thread.new do
        listen_sock = Socket.new(Socket::Constants::AF_LOCAL, Socket::Constants::SOCK_STREAM, 0)
        listen_sock.bind(Addrinfo.unix(path))
        listen_sock.listen(128)
        startup_barrier << true
        conn, _ = listen_sock.accept
        queue << conn.recv(3)
      end
      expect(startup_barrier.pop).to eq true
      thunk = SysLogger::Creators.unix_stream_socket(path)
      client_sock = thunk.call
      client_sock.send "foo", 0
      t.join
      expect(queue.pop).to eq "foo"
    end
  end
end
