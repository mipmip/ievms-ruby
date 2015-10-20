require 'test_helper'

class TestWin7 < Minitest::Test
  include IevmsRubyTestsShared

  def setup
    machine = Ievms::WindowsGuest.new 'IE9 - Win7'
    machine.headless=true
    machine.verbose=false
    machine.start
  end

  def test_timeout_option
    assert_raises {
      run_thor_capture(["cmd", "IE9 - Win7", "ping 127.0.0.1 -n 6 > nul", "--verbose", "--timeout", "3" ])
    }
  end

  def test_ps
    assert_equal true, run_thor_capture(["ps", "IE9 - Win7"]).include?('winlogon.exe')
  end

  def test_help
    assert_equal true, run_thor_capture([]).include?('[vbox name]')
    assert_equal true, run_thor_capture(['help']).include?('[file path]')
  end

  def test_version
    assert_equal Ievms::VERSION, run_thor_capture(['version'])
  end

  def test_copy_from
    FileUtils.rm '/tmp/testdlfile2.txt' if File.exists? '/tmp/testdlfile2.txt'
    out = run_thor_capture ['copy_from',"IE9 - Win7",'C:\ievms.xml', '/tmp/testdlfile2.txt']

    assert_equal out, "[IE9 - Win7] Copying C:\\ievms.xml to /tmp/testdlfile2.txt\n"
    assert_equal true, File.exists?('/tmp/testdlfile2.txt')
  end

  def test_copy_to
    run_thor ['cmd', "IE9 - Win7", 'if exist C:\Users\IEUser\ievms_test_upload3.txt del C:\Users\IEUsers\ievms_test_upload3.txt && Exit']
    FileUtils.rm '/tmp/ievms_test_upload3.txt' if File.exists? '/tmp/ievms_test_upload3.txt'
    `echo "uploadasadmin_yes" > /tmp/ievms_test_upload3.txt`
    out = run_thor_capture ['copy_to',"IE9 - Win7", '/tmp/ievms_test_upload3.txt', 'C:\Users\IEUser\ievms_test_upload3.txt']
    out2 = run_thor_capture ['cat',"IE9 - Win7", 'C:\Users\IEUser\ievms_test_upload3.txt']
    assert_equal "[IE9 - Win7] Copying /tmp/ievms_test_upload3.txt to C:\\Users\\IEUser\\ievms_test_upload3.txt\n", out
    assert_match(/uploadasadmin_yes/, out2)
  end

  def test_copy_to_as_adm
    run_thor ['cmd_as_adm', "IE9 - Win7", 'if exist C:\ievms_test_upload2.txt del C:\ievms_test_upload2.txt && Exit']
    FileUtils.rm '/tmp/ievms_test_upload2.txt' if File.exists? '/tmp/ievms_test_upload2.txt'
    `echo "uploadasadmin_yes" > /tmp/ievms_test_upload2.txt`

    out = run_thor_capture ['copy_to_as_adm',"IE9 - Win7", '/tmp/ievms_test_upload2.txt', 'C:\ievms_test_upload2.txt']
    out2 = run_thor_capture ['cat',"IE9 - Win7", 'C:\ievms_test_upload2.txt']
    assert_equal "[IE9 - Win7] Copying /tmp/ievms_test_upload2.txt to C:\\ievms_test_upload2.txt as Administrator\n", out
    assert_match(/uploadasadmin_yes/, out2)
  end

  def test_reboot
#    sysinfo =  run_thor_capture(['cmd', "IE9 - Win7", 'systeminfo'])
#    print sysinfo
#    boottime1 = sysinfo.lines.find { |line| line.include?("Boot") }
#    print boottime1

    run_thor(['reboot', "IE9 - Win7"])

#    sysinfo2 =  run_thor_capture(['cmd', "IE9 - Win7", 'systeminfo'])
#    boottime2 = sysinfo2.lines.find { |line| line.include?("Boot") }
#    p sysinfo2
#    print boottime2
    #refute_equal boottime1, boottime2
    #FIXME update?
  end

  def test_shutdown
    machine = Ievms::WindowsGuest.new 'IE9 - Win7'
    assert_equal(true, machine.boot_complete?)
    run_thor(['shutdown', "IE9 - Win7"])
    assert_equal(true, machine.powered_off?)
    assert_match(/Already\ powered\ off/ , run_thor_capture(['shutdown', "IE9 - Win7"]))
  end

  def test_cat
    out =  run_thor_capture(['cat', "IE9 - Win7", 'C:\Windows\System32\Drivers\Etc\hosts'])
    assert_match(/rhino\.acme\.com/, out)
  end

  def test_cmd
    out =  run_thor_capture(['cmd', "IE9 - Win7", 'tasklist'])
    assert_match(/winlogon\.exe/, out)
  end

  def test_cmd_adm
    out =  run_thor_capture(['cmd', "IE9 - Win7", 'tasklist'])
    assert_match(/winlogon\.exe/, out)
  end

  #def test_pwrsh_as_adm
  # p run_thor_capture(['pwrsh_as_adm', "IE9 - Win7", 'curl'])
  #end

  # takes 5 minutes
  def test_choco
    cmd1 = run_thor_capture(['choco_uninst', "IE9 - Win7", 'curl'])
    assert_match(/Chocolatey\ is\ not\ installed,\ guess\ you/,cmd1)
    run_thor(['choco_inst', "IE9 - Win7", 'curl'])
    p run_thor_capture(['cmd_as_adm', "IE9 - Win7", 'curl'])
    run_thor(['choco_uninst', "IE9 - Win7", 'curl'])
    p run_thor_capture(['cmd_as_adm', "IE9 - Win7", 'curl'])
  end

  def test_reset_ievms_taskmgr
    machine = Ievms::WindowsGuest.new 'IE9 - Win7'
    machine.run_command_as_admin 'ping 127.0.0.1 -n 30 > nul', true, true
    run_thor(['reset_ievms_taskmgr', "IE9 - Win7"])
    assert_match(/Ready/,run_thor_capture(['cmd', "IE9 - Win7", 'schtasks.exe /Query /TN ievms']))
  end

  private

  def run_thor(args)
  #  args << '--verbose'
    IevmsRb.start(args)
  end

  def run_thor_capture(args)
  #  args << '--verbose'
    out, _  = capture_io do
      IevmsRb.start(args)
    end
    out
  end
end
