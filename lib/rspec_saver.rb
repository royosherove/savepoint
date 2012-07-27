require 'time'
require 'builder'
require 'rspec/core/formatters/base_formatter'

puts "Recording Test Results Initializing..."
class JUnit < RSpec::Core::Formatters::BaseFormatter
  def initialize output
    super output
    @test_results = []
    puts "initi..."
  end

  def example_passed example
    @test_results << example
  end

  def example_failed example
    @test_results << example
  end

  def example_pending example
    @test_results << example
  end

  def failure_details_for example
    exception = example.metadata[:execution_result][:exception]
    exception.nil? ? "" : "#{exception.message}\n#{format_backtrace(exception.backtrace, example).join("\n")}"
  end

  def full_name_for example
    test_name = ""
    current_example_group = example.metadata[:example_group]
    until current_example_group.nil? do
      test_name = "#{current_example_group[:description]}." + test_name
      current_example_group = current_example_group[:example_group]
    end
    test_name << example.metadata[:description]
  end

  def dump_summary duration, example_count, failure_count, pending_count
    puts "HEHEHEHEHE"
    builder = Builder::XmlMarkup.new :indent => 2
    builder.instruct! :xml, :version => "1.0", :encoding => "UTF-8"
    builder.testsuite :errors => 0, :failures => failure_count, :skipped => pending_count, :tests => example_count, :time => duration, :timestamp => Time.now.iso8601 do
      builder.properties
      @test_results.each do |test|
        builder.testcase :classname => full_name_for(test), :name => test.metadata[:full_description], :time => test.metadata[:execution_result][:run_time] do
          case test.metadata[:execution_result][:status]
          when "failed"
            builder.failure :message => "failed #{test.metadata[:full_description]}", :type => "failed" do
              builder.cdata! failure_details_for test
            end
          when "pending" then builder.skipped
          end
        end
      end
    end
    output.puts builder.target!
  end
end