require "minitest/autorun"

class TestWin7 < Minitest::Test
  def setup
    @machine = Ievms::WindowsGuest.new 'IE9 - Win7'
  end

  def test_execute_batch_file

    @machine.upload_file_to_guest(File.join(File.dirname(__FILE__), '_test.bat'), 'C:\Users\IEUser\test.bat')
    @machine.run_bat('C:\Users\IEUser\test.bat')

    assert_equal "OHAI!", @machine.i_can_has_cheezburger?
  end

  def test_execute_batch_file_as_admin
#    @machine.upload_file_to_guest('/Users/pim/.ievms/ievms-ruby-test/_test_as_admin.bat', 'C:\Users\IEUser\test_as_admin.bat')
#    @machine.run_bat_as_admin('C:\Users\IEUser\test_as_admin.bat')
    skip "test this later"
  end
end
