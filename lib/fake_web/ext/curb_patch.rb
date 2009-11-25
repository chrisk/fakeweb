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
          self.body_str = r.body_str
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

    end
  end
end
