require "ievms/version"
require 'open3'
require 'fileutils'
require 'tempfile'

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

    @verbose = false

    def initialize(vbox_name)
      @vbox_name = vbox_name

      is_vm vbox_name
    end

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

    def download_string_from_file_to_guest( guest_path, quiet=false)
      log_stdout "Copying #{guest_path} to tempfile.txt", quiet
      guestcontrol_exec "cmd.exe", "cmd.exe /c copy \"#{guest_path}\" \"E:\\tmpfile.txt\""

      string = IO.read(File.join(IEVMS_HOME,'tmpfile.txt'))
      FileUtils.rm File.join(IEVMS_HOME,'tmpfile.txt')
      string
    end

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

      upload_string_as_file_to_guest(command, 'C:\Users\IEUser\ievms.bat', true)

      guestcontrol_exec "schtasks.exe", "schtasks.exe /run /tn ievms"

      while schtasks_query_ievms.include? 'Running'
        print "."
        sleep 2
      end
      print "\n"
    end

    # execute existing batch file in Windows guest
    def run_command(command, quiet=false)
      log_stdout "Executing command: #{command}", quiet
      out, _, _ = guestcontrol_exec "cmd.exe", "cmd.exe /c \"#{command}\""
      out
    end

    def schtasks_query_ievms
      out, _, _ = guestcontrol_exec "schtasks.exe", "schtasks.exe /query /tn ievms"
      out
    end

    private

    def log_stdout(msg, quiet=true)
      print "[#{@vbox_name}] #{msg}\n" unless quiet
    end

    # execute final guest control shell cmd
    # returns [stdout,stderr,status] from capture3
    def guestcontrol_exec(image, cmd)
      wait_for_guestcontrol(@vbox_name)
      cmd = "VBoxManage guestcontrol \"#{@vbox_name}\" run --username \"#{USERNAME}\" --password '#{PASSWD}' --exe \"#{image}\" -- #{cmd}"
    #  print cmd + "\n"
      return Open3.capture3(cmd)
    end

    # function taken from ievms
    # Pause execution until guest control is available for a virtual machine
    def wait_for_guestcontrol(vboxname)
      run_level = 0
      while run_level < 3 do
        print "Waiting for #{vboxname} to be available for guestcontrol...\n" if @verbose
        out = `VBoxManage showvminfo "#{vboxname}" | grep 'Additions run level:'`
        run_level = out[-2..-2].to_i
        if run_level < 3
          sleep 3
        end
      end
    end

    # Is it a virtual machine in VirtualBox?
    def is_vm(vboxname)
      cmd = "VBoxManage showvminfo \"#{vboxname}\""

      _, stderr, _ = Open3.capture3(cmd)
      if stderr.include? 'Could not find a registered machine named'
        raise "Virtual Machine #{vboxname} does not exist"
      end
    end

  end
end
