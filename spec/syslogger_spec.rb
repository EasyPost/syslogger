describe SysLogger do
  let(:io)     { StringIO.new }
  let(:logger) { SysLogger.new(io) }

  describe '#new' do
    it 'creates a Logger' do
      expect(logger).to be_a SysLogger::Logger
    end
  end

  describe "#appname" do
    it 'returns nil if appname is nil' do
      expect(logger.appname).to be_nil
      logger.info('test')
      expect(io.string).to match(
        /<190>1.* #{Socket.gethostname} - #{Process.pid} - \[meta.*/
      )
    end

    it 'overrides the appname' do
      logger.appname = 'an-appname'
      logger.info('test')
      expect(io.string).to match(
        /<190>1.* #{Socket.gethostname} an-appname #{Process.pid} - \[meta.*/
      )
    end
  end
end
