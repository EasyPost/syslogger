describe SysLogger do
  let(:logger) { SysLogger.new(StringIO.new) }

  describe '#new' do
    it 'creates a Logger' do
      expect(logger).to be_a SysLogger::Logger
    end
  end
end
