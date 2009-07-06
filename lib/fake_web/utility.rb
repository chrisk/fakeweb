module FakeWeb
  module Utility #:nodoc:

    def self.decode_userinfo_from_header(header)
      header.sub(/^Basic /, "").unpack("m").first
    end

    def self.encode_unsafe_chars_in_userinfo(userinfo)
      unsafe_in_userinfo = /[^#{URI::REGEXP::PATTERN::UNRESERVED};&=+$,]|^(#{URI::REGEXP::PATTERN::ESCAPED})/
      userinfo.split(":").map { |user_or_pass|
        URI.escape(user_or_pass, unsafe_in_userinfo)
      }.join(":")
    end

  end
end
