require 'simplecov'

SimpleCov.start do
  add_filter '/test/'
  add_filter '/vendor/'
end

require 'minitest'
require 'minitest/unit'
require 'minitest/autorun'
require 'minitest/pride'
#require 'base64'

#tempdir = File.join(File.dirname(__FILE__), 'tmpout')
#FileUtils.rm_rf(Dir.glob(tempdir+'/*'))

