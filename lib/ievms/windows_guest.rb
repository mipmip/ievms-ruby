require "ievms/version"
require 'open3'
require 'fileutils'
require 'tempfile'
require 'timeout'

# VM admin username
USERNAME = 'IEUser'
# VM admin user password
PASSWD = 'Passw0rd!'

# IEVMS directory
IEVMS_HOME = ENV['HOME']+'/.ievms'

# ievms interface
module Ievms
  class WindowsGuest
    attr_accessor :verbose
    attr_accessor :headless
    attr_accessor :timeout_secs

    def initialize(vbox_name)
      @vbox_name = vbox_name

      check_virtualbox_version
      is_vm?

      @verbose = false
      @headless = true
      @timeout_secs = 600 #default timeout for a single task 5 minutes
    end

    # copy file from guest (win) machine to host machine
    def download_file_from_guest(guest_path, local_path, quiet=false)

      log_stdout "Copying #{guest_path} to #{local_path}", quiet
      # 1 run cp command in machine
      guestcontrol_exec "cmd.exe", "cmd.exe /c copy \"#{guest_path}\" \"E:\\#{File.basename(local_path)}\""

      # 2 copy to tmp location in .ievms
      FileUtils.cp File.join(IEVMS_HOME,File.basename(local_path)), local_path

      # 3 remove tmp file in .ievms
      FileUtils.rm File.join(IEVMS_HOME,File.basename(local_path))
    end

    # Upload a local file to the windows guest
    def upload_file_to_guest(local_path, guest_path, quiet=false)

      # 1 copy to tmp location in .ievms
      FileUtils.cp local_path, File.join(IEVMS_HOME,File.basename(local_path))

      # 2 run cp command in machine
      log_stdout "Copying #{local_path} to #{guest_path}", quiet
      guestcontrol_exec "cmd.exe", "cmd.exe /c copy \"E:\\#{File.basename(local_path)}\" \"#{guest_path}\""

      # 3 remove tmp file in .ievms
      FileUtils.rm File.join(IEVMS_HOME,File.basename(local_path))
    end

    # return string from remote file
    def download_string_from_file_to_guest( guest_path, quiet=false)
      log_stdout "Copying #{guest_path} to tempfile.txt", quiet
      guestcontrol_exec "cmd.exe", "cmd.exe /c copy \"#{guest_path}\" \"E:\\tmpfile.txt\""

      tmpfile = File.join(IEVMS_HOME,'tmpfile.txt')
      if File.exists? tmpfile
        string = IO.read(tmpfile)
        FileUtils.rm tmpfile
      else
        string = ''
      end
      string
    end

    # make remote file from string
    def upload_string_as_file_to_guest(string, guest_path, quiet=false)
      tmp = Tempfile.new('txtfile')
      tmp.write "#{string}\n"
      path = tmp.path
      tmp.rewind
      tmp.close

      upload_file_to_guest(path, guest_path, true)
      FileUtils.rm path
    end

    # Upload a local file to the windows guest as Administator
    def upload_file_to_guest_as_admin(local_path, guest_path, quiet=false)

      log_stdout "Copying #{local_path} to #{guest_path} as Administrator", quiet

      upload_file_to_guest(local_path, 'C:\Users\IEUser\.tempadminfile',true)
      run_command_as_admin('copy C:\Users\IEUser\.tempadminfile '+ guest_path,true)
      run_command 'del C:\Users\IEUser\.tempadminfile', true
    end

    # execute existibg batch file in Windows guest as Administrator
    def run_command_as_admin(command,quiet=false)
      log_stdout "Executing command as administrator: #{command}", quiet

      run_command 'if exist C:\Users\IEUser\ievms.bat del C:\Users\IEUser\ievms.bat && Exit', true
      upload_string_as_file_to_guest('C:\Users\IEUser\ievms_cmd.bat > C:\Users\IEUser\ievms.txt', 'C:\Users\IEUser\ievms.bat', true)

      run_command 'if exist C:\Users\IEUser\ievms.bat del C:\Users\IEUser\ievms_cmd.bat && Exit', true
      upload_string_as_file_to_guest(command, 'C:\Users\IEUser\ievms_cmd.bat', true)

      _ = Timeout::timeout(@timeout_secs) {

        guestcontrol_exec "schtasks.exe", "schtasks.exe /run /tn ievms"

        unless quiet
          print "..."
          while schtasks_query_ievms.include? 'Running'
            print "."
            sleep 1
          end
          print "\n"
        end
      }

      run_command 'if exist C:\Users\IEUser\ievms.bat del C:\Users\IEUser\ievms_cmd.bat && Exit', true
      print download_string_from_file_to_guest 'c:\Users\IEUser\ievms.txt' unless quiet
      download_string_from_file_to_guest 'c:\Users\IEUser\ievms.txt', true
    end

    # execute existing batch file in Windows guest
    def run_command(command, quiet=false)
      log_stdout "Executing command: #{command}", quiet
      out, _, _ = guestcontrol_exec "cmd.exe", "cmd.exe /c \"#{command}\""
      out
    end


    #def run_powershell_cmd(command, quiet=false)
    #  run_command '@powershell -NoProfile -Command "' + command +'"', quiet
    #end

    def run_powershell_cmd_as_admin(command, quiet=false)
      run_command_as_admin  '@powershell -NoProfile -ExecutionPolicy unrestricted -Command "' + command + '"', quiet
    end

    # shutdown windows machine
    def shutdown(quiet=false)
      if powered_off?
        log_stdout "Already powered off.", false
      else
        log_stdout "shutting down ...", quiet
        run_command_as_admin "shutdown.exe /s /f /t 0", quiet
        wait_for_shutdown
      end
    end

    # start windows, finish as soon as boot is complete
    def start(quiet=false)
      if powered_off?
        log_stdout "starting ...", quiet

        if(@headless)
          type = 'headless'
        else
          type = 'gui'
        end
        `VBoxManage startvm "#{@vbox_name}" --type #{type}`
        wait_for_guestcontrol
      else
        log_stdout "Already started ...", quiet
      end
    end

    # reboot windows machine
    def reboot(quiet=false)
      log_stdout "rebooting...", quiet
      shutdown(true)
      start(true)
    end

    # show status of administrative ievms task.
    def schtasks_query_ievms
      out, _, _ = guestcontrol_exec "schtasks.exe", "schtasks.exe /query /tn ievms"
      out
    end

    # install choco package(s)
    def choco_install(pkg, quiet=false)
      if ! chocolatey?
        log_stdout "First time.. installing Chocolatey first", quiet
        install_chocolatey
      end

      log_stdout "Installing with choco: #{pkg} \n", quiet
      run_powershell_cmd_as_admin("choco install -y #{pkg}", false)
    end

    # uninstall package(s)
    def choco_uninstall(pkg,quiet=false)
      if chocolatey?
        log_stdout "Uninstalling with choco: #{pkg} \n", false
        run_powershell_cmd_as_admin("cuninst -y #{pkg}", false)
      else
        log_stdout "Chocolatey is not installed, guess you don't need to uninstall anything.", quiet
      end
    end

    # is chocolatey installed
    def chocolatey?
      out = run_command_as_admin('@powershell -Command "choco"',false)
      if out.include?("CommandNotFoundException")
        return false
      else
        return true
      end
    end

    # install the Chocolatey Package Manager for Windows
    def install_chocolatey(quiet=false)
      log_stdout "Installing Chocolatey", quiet
      run_command_as_admin('@powershell -NoProfile -ExecutionPolicy unrestricted -Command "(iex ((new-object net.webclient).DownloadString(\'https://chocolatey.org/install.ps1\'))) >$null 2>&1" && SET PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin')
      reboot
    end

    # end the administrative task
    def end_ievms_task(quiet)
      run_command('schtasks.exe /End /TN ievms', quiet)
    end

    ###############################################################

    private

    def log_stdout(msg, quiet=true)
      print "[#{@vbox_name}] #{msg}\n" unless quiet
    end

    # execute final guest control shell cmd
    # returns [stdout,stderr,status] from capture3
    def guestcontrol_exec(image, cmd)

      _ = Timeout::timeout(@timeout_secs) {
        wait_for_guestcontrol
        cmd = "VBoxManage guestcontrol \"#{@vbox_name}\" run --username \"#{USERNAME}\" --password '#{PASSWD}' --exe \"#{image}\" -- #{cmd}"

        log_stdout cmd, false if @verbose

        return Open3.capture3(cmd)
      }

    end


    # Pause execution until guest control is available for a virtual machine
    def wait_for_guestcontrol
      until boot_complete? do
        print "Waiting for #{@vbox_name} to be available for guestcontrol...\n" if @verbose
        sleep 3
      end
    end

    # Pause execution until guest machine has shut down
    def wait_for_shutdown
      until powered_off? do
        print "Waiting for #{@vbox_name} to be finish shutdown...\n" if @verbose
        sleep 3
      end
    end

    # raise when version is not compatible
    def check_virtualbox_version
      if Gem::Version.new(`VBoxManage -v`.strip.split('r')[0]) < Gem::Version.new('5.0.6')
        raise "VirtualBox >= 5.0.6 is not installed"
      end
    end

    # raise when name is not a virtual machine in VirtualBox
    def is_vm?
      cmd = "VBoxManage showvminfo \"#{@vbox_name}\""
      _, stderr, _ = Open3.capture3(cmd)
      if stderr.include? 'Could not find a registered machine named'
        raise "Virtual Machine #{@vbox_name} does not exist"
      end
    end

    # true when machine powered off
    def powered_off?
      out = `VBoxManage showvminfo "#{@vbox_name}" | grep "State:"`
      if out.include?('powered off')
        return true
      end
    end

    # return true when run level is 3 boot complete
    def boot_complete?
      out = `VBoxManage showvminfo "#{@vbox_name}" | grep 'Additions run level:'`
      if out[-2..-2].to_i == 3
        return true
      end
    end

  end
end
