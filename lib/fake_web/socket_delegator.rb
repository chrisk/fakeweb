module FakeWeb

  class SocketDelegator #:nodoc:

    def initialize(delegate=nil)
      @delegate = nil
    end

    def method_missing(method, *args, &block)
      if @delegate
        @delegate.send(method, *args, &block)
      else
        self.send("my_#{method}", *args, &block)
      end
    end

    def my_closed?
      @closed ||= true
    end

    def my_readuntil(*args)
    end
  end

end
