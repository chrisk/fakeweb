module FakeWeb
  module Utility #:nodoc:

    def self.decode_userinfo_from_header(header)
      header.sub(/^Basic /, "").unpack("m").first
    end

    def self.encode_unsafe_chars_in_userinfo(userinfo)
      unsafe_in_userinfo = /[^#{URI::REGEXP::PATTERN::UNRESERVED};&=+$,]|^(#{URI::REGEXP::PATTERN::ESCAPED})/
      userinfo.split(":").map { |part| URI.escape(part, unsafe_in_userinfo) }.join(":")
    end

    def self.strip_default_port_from_uri(uri)
      case uri
      when %r{^http://}  then uri.sub(%r{:80(/|$)}, '\1')
      when %r{^https://} then uri.sub(%r{:443(/|$)}, '\1')
      else uri
      end
    end

    # Array#permutation wrapper for 1.8.6-compatibility. It only supports the
    # simple case that returns all permutations (so it doesn't take a numeric
    # argument).
    def self.simple_array_permutation(array, &block)
      # use native implementation if it exists
      return array.permutation(&block) if array.respond_to?(:permutation)

      yield array if array.length <= 1

      array.length.times do |i|
        rest = array.dup
        picked = rest.delete_at(i)
        next if rest.empty?

        simple_array_permutation(rest) do |part_of_rest|
          yield [picked] + part_of_rest
        end
      end

      array
    end

  end
end
