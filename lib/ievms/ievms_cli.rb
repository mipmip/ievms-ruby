class IevmsRb < Thor
  class_option :verbose, :desc => 'Be more verbose', :type => :boolean, :aliases => '-v'
  class_option :timeout, :desc => 'Timeout in seconds', :type => :numeric

  def initialize(*args)
    super

    if args[0].count > 0
      @machine = Ievms::WindowsGuest.new args[0][0]
      @machine.verbose = true if options[:verbose]
      @machine.timeout_secs = options[:timeout] if options[:timeout]
    end
  end

  desc "cat [vbox name] [file path]", "cat file from path in Win vbox"
  def cat(vbox_name,guest_path)
    print @machine.download_string_from_file_to_guest guest_path, true
  end

  desc "ps [vbox name]", "Show running tasks in Win vbox"
  def ps(vbox_name)
    print @machine.run_command "tasklist"
  end

  desc "shutdown [vbox name]", "Shutdown Win vbox"
  def shutdown(vbox_name)
    @machine.shutdown
  end

  option :gui, :desc => 'start as gui', :type => :boolean
  desc "start [vbox name]", "Start Win box"
  def start(vbox_name)
    @machine.headless = false if options[:gui] 
    @machine.start
  end

  desc "reboot [vbox name]", "Reboot Win box"
  def reboot(vbox_name)
    @machine.reboot
  end

  desc "copy_to_as_adm [vbox name] [local file] [path in vbox]", "Copy local file to Win vbox as Administrator"
  def copy_to_as_adm(vbox_name,local_path, guest_path)
    @machine.upload_file_to_guest_as_admin(local_path, guest_path, false)
  end

  desc "copy_to [vbox name] [local file] [path in vbox]", "Copy local file to Win vbox"
  def copy_to(vbox_name,local_path, guest_path)
    @machine.upload_file_to_guest(local_path, guest_path, false)
  end

  desc "copy_from [vbox name] [path in vbox] [local file]", "Copy file from Win vbox to local path"
  def copy_from(vbox_name, guest_path, local_path)
    @machine.download_file_from_guest(guest_path, local_path, false)
  end

  desc "cmd [vbox name] [command to execute]", "Run command with cmd.exe in Win vbox"
  def cmd(vbox_name,command)
    print @machine.run_command command
    print "\n"
  end

  desc "cmd_adm [vbox name] [command to execute]", "Run command as Administrator with cmd.exe in Win vbox"
  def cmd_as_adm(vbox_name,command)
    print @machine.run_command_as_admin command
  end

#  desc "pwrsh [vbox name] [command to execute]", "Run command with PowerShell in Win vbox"
#  def pwrsh(vbox_name,command)
#    print @machine.run_powershell_cmd command
#  end

  desc "pwrsh_as_adm [vbox name] [command to execute]", "Run command as Administrator with PowerShell in Win vbox"
  def pwrsh_as_adm(vbox_name,command)
    print @machine.run_powershell_cmd_as_admin command
  end

  desc "choco_inst [vbox name] [package]", "Install package in win box with Chocolatey"
  def choco_inst(vbox_name,pkg)
    @machine.choco_install pkg
  end

  desc "choco_uninst [vbox name] [package]", "Uninstall package in win box with Chocolatey"
  def choco_uninst(vbox_name,pkg)
    @machine.choco_uninstall pkg
  end

  private

end

