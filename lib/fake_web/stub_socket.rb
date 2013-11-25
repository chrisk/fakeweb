module FakeWeb
  class StubSocket #:nodoc:

    attr_accessor :read_timeout, :continue_timeout

    def initialize(*args)
    end

    def closed?
      @closed ||= true
    end

    def readuntil(*args)
    end

  end
end
