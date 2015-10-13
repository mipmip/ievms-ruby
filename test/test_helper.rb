require 'simplecov'

SimpleCov.start do
  add_filter '/test/'
  add_filter '/vendor/'
end

require 'minitest'
require 'minitest/unit'
require 'minitest/autorun'
require 'minitest/pride'

require "codeclimate-test-reporter"
CodeClimate::TestReporter.start

module IevmsRubyTestsShared

  def ensure_machine_running vbox_name

    iectrl = `iectrl status "#{vbox_name}"`
    if not iectrl.include?('RUNNING')
      iectrl = `iectrl start "#{vbox_name}"`
      sleep 5
      iectrl = `iectrl status "#{vbox_name}"`
      if not iectrl.include?('RUNNING')
        iectrl = `VBoxManage startvm --type headless "#{vbox_name}"`
        sleep 5
      end

      IevmsRb.start(['ps', "IE9 - Win7"])
    end

  end
end
