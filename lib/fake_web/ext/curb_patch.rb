if defined?(Curl::Easy)
  module Curl
    class Easy

      class << self
        def perform_with_fakeweb(uri)
          if FakeWeb.registered_uri?(:get, uri)
            FakeWeb::Registry.instance.curl_response_for(:get, uri)
          elsif FakeWeb.allow_net_connect?
            perform_without_fakeweb(uri)
          else
            raise FakeWeb::NetConnectNotAllowedError,
                  "Real HTTP connections are disabled. Unregistered request: GET #{uri}"
          end
        end
        alias_method :perform_without_fakeweb, :perform
        alias_method :perform, :perform_with_fakeweb
      end

    end
  end
end
