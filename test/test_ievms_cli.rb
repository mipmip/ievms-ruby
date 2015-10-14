require 'test_helper'
require 'thor'
require 'ievms/ievms_cli'
require 'ievms/windows_guest'
require 'timeout'

class TestWin7 < Minitest::Test
  include IevmsRubyTestsShared


  def setup
    ensure_machine_running("IE9 - Win7")
  end

  def test_timeout_option
    assert_raises {
      run_capture(["cmd", "IE9 - Win7", "ping 127.0.0.1 -n 6 > nul", "--verbose", "--timeout", "3" ])
    }
  end

  def test_ps
    assert_equal true, run_capture(["ps", "IE9 - Win7"]).include?('winlogon.exe')
  end

  def test_help
    assert_equal true, run_capture([]).include?('[vbox name]')
    assert_equal true, run_capture(['help']).include?('[file path]')
  end

  def test_copy_from
    FileUtils.rm '/tmp/testdlfile2.txt' if File.exists? '/tmp/testdlfile2.txt'
    out = run_capture ['copy_from',"IE9 - Win7",'C:\ievms.xml', '/tmp/testdlfile2.txt']

    assert_equal out, "[IE9 - Win7] Copying C:\\ievms.xml to /tmp/testdlfile2.txt\n"
    assert_equal true, File.exists?('/tmp/testdlfile2.txt')
  end

  def test_copy_to
    IevmsRb.start ['cmd', "IE9 - Win7", 'if exist C:\Users\IEUser\ievms_test_upload3.txt del C:\Users\IEUsers\ievms_test_upload3.txt && Exit']
    FileUtils.rm '/tmp/ievms_test_upload3.txt' if File.exists? '/tmp/ievms_test_upload3.txt'
    `echo "uploadasadmin_yes" > /tmp/ievms_test_upload3.txt`
    out = run_capture ['copy_to',"IE9 - Win7", '/tmp/ievms_test_upload3.txt', 'C:\Users\IEUser\ievms_test_upload3.txt']
    out2 = run_capture ['cat',"IE9 - Win7", 'C:\Users\IEUser\ievms_test_upload3.txt']
    assert_equal "[IE9 - Win7] Copying /tmp/ievms_test_upload3.txt to C:\\Users\\IEUser\\ievms_test_upload3.txt\n", out
    assert_match(/uploadasadmin_yes/, out2)
  end

  def test_copy_to_as_adm
    IevmsRb.start ['cmd_as_adm', "IE9 - Win7", 'if exist C:\ievms_test_upload2.txt del C:\ievms_test_upload2.txt && Exit']
    FileUtils.rm '/tmp/ievms_test_upload2.txt' if File.exists? '/tmp/ievms_test_upload2.txt'
    `echo "uploadasadmin_yes" > /tmp/ievms_test_upload2.txt`

    out = run_capture ['copy_to_as_adm',"IE9 - Win7", '/tmp/ievms_test_upload2.txt', 'C:\ievms_test_upload2.txt']
    out2 = run_capture ['cat',"IE9 - Win7", 'C:\ievms_test_upload2.txt']
    assert_equal "[IE9 - Win7] Copying /tmp/ievms_test_upload2.txt to C:\\ievms_test_upload2.txt as Administrator\n", out
    assert_match(/uploadasadmin_yes/, out2)
  end

  def test_reboot
    sysinfo =  run_capture(['cmd', "IE9 - Win7", 'systeminfo'])
    boottime1 = sysinfo.lines.find { |line| line.include?("Boot") }
    IevmsRb.start(['reboot', "IE9 - Win7"])
    sleep 5
    IevmsRb.start(['ps', "IE9 - Win7"])

    sysinfo2 =  run_capture(['cmd', "IE9 - Win7", 'systeminfo'])
    boottime2 = sysinfo2.lines.find { |line| line.include?("Boot") }
    refute_equal boottime1, boottime2
  end

  def test_shutdown
    iectrl1 = `iectrl status "IE9 - Win7"`
    assert_match(/RUNNING/, iectrl1)

    IevmsRb.start(['shutdown', "IE9 - Win7"])
    sleep 5

    iectrl2 = `iectrl status "IE9 - Win7"`
    refute_match(/RUNNING/, iectrl2)
  end

  def test_cat
    out =  run_capture(['cat', "IE9 - Win7", 'C:\Windows\System32\Drivers\Etc\hosts'])
    assert_match(/rhino\.acme\.com/, out)
  end

  def test_cmd
    out =  run_capture(['cmd', "IE9 - Win7", 'tasklist'])
    assert_match(/winlogon\.exe/, out)
  end

  def test_cmd_adm
    out =  run_capture(['cmd', "IE9 - Win7", 'tasklist'])
    assert_match(/winlogon\.exe/, out)
  end

  private
  def run_capture(args)
    out, _  = capture_io do
      IevmsRb.start(args)
    end
    out
  end
end
