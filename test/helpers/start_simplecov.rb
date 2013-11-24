module FakeWebTestHelper
  module CodeCoverage
    def start_simplecov
      return unless coverage_supported_by_this_ruby?
      return if !ENV['AUTOTEST'].nil?

      require 'simplecov'
      require 'simplecov-console'

      SimpleCov.start do
        add_filter "/test/"

        minimum_coverage 100 if running_all_tests?
        command_name SIMPLECOV_COMMAND_NAME if child_test_process?
        formatter simplecov_formatter_class
      end
    end

    def simplecov_formatter_class
      include SimpleCov::Formatter
      if html_report_requested?
        MultiFormatter[HTMLFormatter, Console]
      else
        Console
      end
    end

    def running_all_tests?
      ENV['TEST'].nil?
    end

    def child_test_process?
      defined?(SIMPLECOV_COMMAND_NAME)
    end

    def html_report_requested?
      !ENV["COVERAGE_REPORT"].nil?
    end

    def coverage_supported_by_this_ruby?
      RUBY_VERSION >= "1.9.0"
    end

    extend self
  end
end

FakeWebTestHelper::CodeCoverage.start_simplecov
