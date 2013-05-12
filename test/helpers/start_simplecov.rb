module FakeWebTestHelper
  def self.start_simplecov
    return unless RUBY_VERSION >= "1.9.0"
    return if !ENV['AUTOTEST'].nil?

    require 'simplecov'
    require 'simplecov-console'

    SimpleCov.start do
      add_filter "/test/"
      minimum_coverage 100

      if defined?(SIMPLECOV_COMMAND_NAME)
        command_name SIMPLECOV_COMMAND_NAME
      end

      if !ENV["COVERAGE_REPORT"].nil?
        formatter SimpleCov::Formatter::MultiFormatter[
          SimpleCov::Formatter::HTMLFormatter,
          SimpleCov::Formatter::Console
        ]
      else
        formatter SimpleCov::Formatter::Console
      end
    end
  end
end

FakeWebTestHelper.start_simplecov
