require 'simplecov'
require 'thor'
require 'timeout'

SimpleCov.start do
  add_filter '/test/'
  add_filter '/vendor/'
end

require 'ievms/ievms_cli'
require 'ievms/windows_guest'

require 'minitest'
require 'minitest/unit'
require 'minitest/autorun'
require 'minitest/pride'

require "codeclimate-test-reporter"
CodeClimate::TestReporter.start

machine = Ievms::WindowsGuest.new 'IE9 - Win7'
machine.headless=true
machine.verbose=false
machine.restore_clean_snapshot
machine = nil

module IevmsRubyTestsShared

  def initialize(name = nil)
    print "Running test case: #{name}\n"
    @test_name = name
    super(name) unless name.nil?
  end

end
