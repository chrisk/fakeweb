if defined?(Curl::Easy)

  # TODO: I'm sure there's a better way to do this than a global
  $reusable_instance = Curl::Easy.new("")

  module Curl
    class Easy

      class << self
        def new_with_fakeweb(*args, &block)
          obj = $reusable_instance.dup
          obj.send :initialize, *args, &block
          obj
        end
        alias_method :new_without_fakeweb, :new
        alias_method :new, :new_with_fakeweb

        def perform_with_fakeweb(url)
          curl = new(url)
          curl.perform
          curl
        end
        alias_method :perform_without_fakeweb, :perform
        alias_method :perform, :perform_with_fakeweb
      end

      attr_accessor :body_str

      def initialize(url = nil, &block)
        self.url = url
        yield if block_given?
      end

      def perform_with_fakeweb
        if FakeWeb.registered_uri?(:get, url)
          r = FakeWeb::Registry.instance.curl_response_for(:get, url)
          __process_body(r.body_str)
          true
        elsif FakeWeb.allow_net_connect?
          perform_without_fakeweb
        else
          raise FakeWeb::NetConnectNotAllowedError,
                "Real HTTP connections are disabled. Unregistered request: GET #{url}"
        end
      end
      alias_method :perform_without_fakeweb, :perform
      alias_method :perform, :perform_with_fakeweb


      # TODO: shouldn't really be adding new methods. Put this somewhere else?
      def __process_body(body)
        # TODO: lock around this so another thread doesn't see the momentarily-nil proc?
        body_handler = self.on_body
        self.on_body(&body_handler) unless body_handler.nil?

        if body_handler.nil?
          self.body_str = body
        else
          self.body_str = nil
          handler_return_value = body_handler.call(body)
          if !handler_return_value.is_a?(Integer)
            FakeWeb::Utility.rb_warn "Curl data handlers should return the number of bytes read as an Integer", caller[1]
          elsif handler_return_value != body.length
            # NOTE: Curb docs claim this should be an AbortedByCallbackError, but it raises a WriteError
            raise Curl::Err::WriteError, "Failed writing received data to disk/application"
          end
        end
      end

    end
  end
end
