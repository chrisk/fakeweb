module FakeWeb
  class StubSocket #:nodoc:

    Net::BufferedIO.instance_methods.grep(/_timeout$/).each do |timeout|
      attr_accessor timeout
    end

    def initialize(*args)
    end

    def closed?
      @closed ||= true
    end

    def close
    end

    def readuntil(*args)
    end
  end
end
