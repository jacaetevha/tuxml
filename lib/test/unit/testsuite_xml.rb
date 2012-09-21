require 'test/unit/testsuite'
require 'rexml/document'
require 'time'

module Test
  module Unit
    class TestSuite
      def run_with_timing(result, &block)
        @before_time = Time.now
        run_without_timing(result, &block)
      ensure
        after_time = Time.now.to_f
        @elapsed_time = after_time - @before_time.to_f
      end
      alias_method :run_without_timing, :run
      alias_method :run, :run_with_timing

      def xml_element
        node = if @tests.first.is_a?(TestSuite)
          REXML::Element.new("testsuites")
        else
          testsuite = REXML::Element.new("testsuite")
          testsuite.add_attributes(
            'name' => @name,
            'tests' => test_count.to_s,
            'failures' => failure_count.to_s,
            'errors' => error_count.to_s,
            'time' => @elapsed_time.to_s,
            'timestamp' => @before_time.xmlschema
          )
          testsuite
        end
        
        @tests.each do |test|
          xml_element = test.xml_element
          node.elements << xml_element if xml_element
        end
        return nil if node.elements.empty?
        node
      end
      
      def test_count
        @tests.size
      end
      
      def failure_count
        @tests.inject(0) { |sum, ea| sum + ea.failure_count }
      end
      
      def error_count
        @tests.inject(0) { |sum, ea| sum + ea.error_count }
      end
    end
  end
end
