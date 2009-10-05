require File.join(File.dirname(__FILE__), "test_helper")

class TestOtherNetHttpLibraries < Test::Unit::TestCase

  def capture_output_from_requiring(*libs)
    requires = libs.map { |lib| "require '#{lib}'" }.join("; ")
    fakeweb_dir = "#{File.dirname(__FILE__)}/../lib"
    vendor_dirs = Dir["#{File.dirname(__FILE__)}/vendor/*/lib"]
    load_path_opts = vendor_dirs.unshift(fakeweb_dir).map { |dir| "-I#{dir}" }.join(" ")

    # TODO: use the same Ruby executable that this test was invoked with
    `ruby #{load_path_opts} -e "#{requires}" 2>&1`
  end

  def test_requiring_samuel_before_fakeweb_prints_warning
    output = capture_output_from_requiring "samuel", "fakeweb"
    assert_match %r(Warning: FakeWeb was loaded after Samuel), output
  end

  def test_requiring_samuel_after_fakeweb_does_not_print_warning
    output = capture_output_from_requiring "fakeweb", "samuel"
    assert output.empty?
  end

end
