module FakeWeb

  class SocketDelegator #:nodoc:

    def initialize(delegate=nil)
      @delegate = nil
    end

    def method_missing(method, *args, &block)
      return @delegate.send(method, *args, &block) if @delegate
      return self.send("my_#{method}", *args, &block)
    end

    def my_closed?
      @closed ||= true
    end

    def my_readuntil(*args)
    end
  end

end
