require 'test_helper'
require 'ievms/windows_guest'
require 'timeout'

class TestWin7 < Minitest::Test
  def setup
    @machine = Ievms::WindowsGuest.new 'IE9 - Win7'
  end

  def test_non_existing_guest
    assert_raises {
      _ = Ievms::WindowsGuest.new 'Non Existing Guest'
    }
  end

  def test_not_running_machine_time_out

    assert_raises {
      _ = Timeout::timeout(5) {
        standbymachine = Ievms::WindowsGuest.new 'standbymachine'
        standbymachine.verbose = true
        standbymachine.run_command "dir"
      }
    }

  end

  def test_execute_batch_file

    @machine.run_command 'if exist C:\Users\IEUser\test.bat del C:\Users\IEUser\test.bat && Exit'
    @machine.run_command 'if exist C:\Users\IEUser\EmptyFile.txt del C:\Users\IEUser\EmptyFile.txt && Exit'

    @machine.upload_file_to_guest(File.join(File.dirname(__FILE__), '_test.bat'), 'C:\Users\IEUser\test.bat')
    @machine.run_bat('C:\Users\IEUser\test.bat')
    output_file_exists = @machine.run_command 'if exist C:\Users\IEUser\EmptyFile.txt echo EmptyFileExist && Exit'

    assert_equal true, output_file_exists.include?('EmptyFileExist')
  end

  def test_execute_command

    dir_output = @machine.run_command('cd c:\Users\IEUser & dir')
    assert_equal true, dir_output.include?('Desktop')
  end

  def test_execute_batch_file_as_admin
    @machine.run_command_as_admin 'if exist C:\Users\IEUser\test_as_admin.bat del C:\Users\IEUser\test_as_admin.bat && Exit'
    @machine.run_command_as_admin 'if exist C:\EmptyFile2.txt del C:\EmptyFile2.txt && Exit'

    @machine.upload_file_to_guest(File.join(File.dirname(__FILE__), '_test_as_admin.bat'), 'C:\Users\IEUser\test_as_admin.bat')
    @machine.run_bat_as_admin('C:\Users\IEUser\test_as_admin.bat')
    output_file_exists = @machine.run_command 'if exist C:\EmptyFile2.txt echo EmptyFile2Exist && Exit'

    assert_equal true, output_file_exists.include?('EmptyFile2Exist')
  end
end
