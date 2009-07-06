require File.join(File.dirname(__FILE__), "test_helper")

class TestUtility < Test::Unit::TestCase

  def test_decode_userinfo_from_header_handles_basic_auth
    authorization_header = "Basic dXNlcm5hbWU6c2VjcmV0"
    userinfo = FakeWeb::Utility.decode_userinfo_from_header(authorization_header)
    assert_equal "username:secret", userinfo
  end

  def test_encode_unsafe_chars_in_userinfo_does_not_encode_userinfo_safe_punctuation
    userinfo = "user;&=+$,:secret"
    assert_equal userinfo, FakeWeb::Utility.encode_unsafe_chars_in_userinfo(userinfo)
  end

  def test_encode_unsafe_chars_in_userinfo_does_not_encode_rfc_3986_unreserved_characters
    userinfo = "-_.!~*'()abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789:secret"
    assert_equal userinfo, FakeWeb::Utility.encode_unsafe_chars_in_userinfo(userinfo)
  end

  def test_encode_unsafe_chars_in_userinfo_does_encode_other_characters
    userinfo, safe_userinfo = 'us#rn@me:sec//ret?"', 'us%23rn%40me:sec%2F%2Fret%3F%22'
    assert_equal safe_userinfo, FakeWeb::Utility.encode_unsafe_chars_in_userinfo(userinfo)
  end

end
