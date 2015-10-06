#!/usr/bin/ruby

require 'open3'
require 'fileutils'

USERNAME='IEUser'
# VM admin user password
PASSWD='Passw0rd!'

IEVMS_HOME = ENV['HOME']+'/.ievms'
###########################################################

class VirtualBoxMachine
  def initialize(vbox_name)
    @vbox_name = vbox_name

    is_vm vbox_name
    wait_for_guestcontrol(vbox_name)

  end

  # Copy a file to the virtual machine from the ievms home folder.
  def copy_to_vm src ,dest
    print "Copying #{src} to #{dest}\n"
    guestcontrol_exec "cmd.exe", "cmd.exe /c copy \"E:\\#{src}\" \"#{dest}\""
  end

  def upload_file_to_guest(local_path, guest_path)

    # 1 copy to tmp location in .ievms
    FileUtils.cp local_path, File.join(IEVMS_HOME,File.basename(local_path))

    # 2 run cp command in machine
    copy_to_vm File.basename(local_path), guest_path

    # 3 remove tmp file in .ievms
    FileUtils.rm File.join(IEVMS_HOME,File.basename(local_path))
  end

  def run_bat_as_admin(guest_path)
    print "Executing as administrator #{guest_path}\n"

    guestcontrol_exec "cmd.exe", "cmd.exe /c \"echo #{guest_path} > C:\\Users\\IEUser\\ievms.bat\""
    guestcontrol_exec "schtasks.exe", "schtasks.exe /run /tn ievms"

  end

  def run_bat guest_path
    print "Executing #{guest_path}\n"
    guestcontrol_exec "cmd.exe", "cmd.exe /c \"#{guest_path}\""
  end

  private

  # execute final guest control shell cmd
  def guestcontrol_exec image, cmd
    cmd = "VBoxManage guestcontrol \"#{@vbox_name}\" run --username \"#{USERNAME}\" --password '#{PASSWD}' --exe \"#{image}\" -- #{cmd}"
    print cmd + "\n"
    _, _, _ = Open3.capture3(cmd)
  end

  # function taken from ievms
  # Pause execution until guest control is available for a virtual machine
  def wait_for_guestcontrol vboxname
    run_level = 0
    while run_level < 3 do
      print "Waiting for #{vboxname} to be available for guestcontrol...\n"
      out = `VBoxManage showvminfo "#{vboxname}" | grep 'Additions run level:'`
      run_level = out[-2..-2].to_i
      if run_level < 3
        sleep 3
      end
    end
  end

  # Is it a virtual machine in VirtualBox?
  def is_vm vboxname

    cmd = "VBoxManage showvminfo \"#{vboxname}\""

    _, stderr, _ = Open3.capture3(cmd)
    if stderr.include? 'Could not find a registered machine named'
      raise "Virtual Machine #{vboxname} does not exist"
    end
  end

end

###############################

vboxname = 'IE9 - Win7'
machine = VirtualBoxMachine.new vboxname
machine.upload_file_to_guest('/Users/pim/.ievms/provision_windows/test.bat', 'C:\Users\IEUser\test.bat')
machine.run_bat('C:\Users\IEUser\test.bat')
machine.upload_file_to_guest('/Users/pim/.ievms/provision_windows/test_as_admin.bat', 'C:\Users\IEUser\test_as_admin.bat')
machine.run_bat_as_admin('C:\Users\IEUser\test_as_admin.bat')
