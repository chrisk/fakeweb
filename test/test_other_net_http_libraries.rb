require 'test_helper'

# Each of these tests shells out to `ruby -rfakeweb ...` so
# we can see how FakeWeb behaves with different combinations of
# other gems loaded without polluting the rest of our tests.
class TestOtherNetHttpLibraries < Test::Unit::TestCase

  def capture_output_from_requiring(libs, additional_code = "")
    requires = libs.map { |lib| "require '#{lib}'" }.join("; ")
    fakeweb_test_dir = File.dirname(__FILE__)
    load_paths = [fakeweb_test_dir,
                  File.expand_path("#{fakeweb_test_dir}/../lib")]
    load_paths += Dir["#{fakeweb_test_dir}/vendor/*/lib"]
    load_path_opts = load_paths.map { |dir| "-I#{dir}" }.join(" ")

    # Since each test in this class starts a new Ruby process to run
    # implementation code, the main test process's Coverage database
    # won't know that code's been exercised. Instead, you have to load
    # SimpleCov at the start of each process, collect the results as
    # they exit, then finally merge them with the original test
    # process's stats at the end of the suite. SimpleCov is magic and
    # does this for you (!) as long as you inform it re: the haps by
    # providing a unique, stable identifier for each part.
    # We can just use the name of the current test, since we only
    # start one process per test. The original process (comprising
    # the rest of the tests) will just get the default name
    # "Unit Tests".
    simplecov_code = "SIMPLECOV_COMMAND_NAME = '#{current_test_name}'; require 'helpers/start_simplecov'"

    output = `#{ruby_path} #{current_ruby_opts.join(' ')} #{load_path_opts} -e "#{simplecov_code}; #{requires}; #{additional_code}" 2>&1`
    remove_warnings_from_gems_and_stdlib(output)
  end

  def test_requiring_samuel_before_fakeweb_prints_warning
    output = capture_output_from_requiring %w(samuel fakeweb)
    assert_match %r(Warning: FakeWeb was loaded after Samuel), output
  end

  def test_requiring_samuel_after_fakeweb_does_not_print_warning
    output = capture_output_from_requiring %w(fakeweb samuel)
    assert_empty output
  end

  def test_requiring_right_http_connection_before_fakeweb_and_then_connecting_does_not_print_warning
    additional_code = "Net::HTTP.start('example.com')"
    output = capture_output_from_requiring %w(right_http_connection fakeweb), additional_code
    assert_empty output
  end

  def test_requiring_right_http_connection_after_fakeweb_and_then_connecting_prints_warning
    additional_code = "Net::HTTP.start('example.com')"
    output = capture_output_from_requiring %w(fakeweb right_http_connection), additional_code
    assert_match %r(Warning: RightHttpConnection was loaded after FakeWeb), output
  end

end
