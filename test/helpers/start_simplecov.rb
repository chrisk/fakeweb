module FakeWebTestHelper
  module CodeCoverage
    def start_simplecov
      return unless coverage_supported_by_this_ruby?
      return if !ENV['AUTOTEST'].nil?

      require 'simplecov'
      require 'simplecov-console'

      SimpleCov.start do
        add_filter "/test/"

        minimum_coverage 100 if this_process_responsible_for_coverage_reporting?
        command_name SIMPLECOV_COMMAND_NAME if child_test_process?
        formatter simplecov_formatter_class
        coverage_dir "coverage/#{ENV['TEST_ENV_NUMBER']}" if !ENV['TEST_ENV_NUMBER'].nil?
      end
    end

    def simplecov_formatter_class
      include SimpleCov::Formatter
      formatters = []
      if this_process_responsible_for_coverage_reporting?
        formatters << Console
        formatters << HTMLFormatter if html_report_requested?
      end
      MultiFormatter.new formatters
    end

    def this_process_responsible_for_coverage_reporting?
      running_all_tests? && !child_test_process?
    end

    def running_all_tests?
      ARGV == Dir["test/test_*.rb"] - ["test/test_helper.rb"]
    end

    def child_test_process?
      defined?(SIMPLECOV_COMMAND_NAME)
    end

    def html_report_requested?
      !ENV["COVERAGE_REPORT"].nil?
    end

    def coverage_supported_by_this_ruby?
      RUBY_VERSION >= "1.9.0" && RUBY_ENGINE != "rbx"
    end

    extend self
  end
end

FakeWebTestHelper::CodeCoverage.start_simplecov
