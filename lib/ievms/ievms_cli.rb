class IevmsRb < Thor

  desc "cat [vbox name] [file path]", "cat file from path in Win vbox"
  def cat(vbox_name,guest_path)
    init vbox_name
    print @machine.download_string_from_file_to_guest guest_path, true
  end

  desc "ps [vbox name]", "Show running tasks in Win vbox"
  def ps(vbox_name)
    init vbox_name
    print @machine.run_command "tasklist"
  end

  desc "shutdown [vbox name]", "Shutdown Win vbox"
  def shutdown(vbox_name)
    init vbox_name
    print @machine.run_command "shutdown.exe /s /f /t 0"
  end

  desc "reboot [vbox name]", "Reboot Win box"
  def reboot(vbox_name)
    init vbox_name
    print @machine.run_command "shutdown.exe /r /f /t 0"
  end

  desc "copy_to_as_adm [vbox name] [local file] [path in vbox]", "Copy local file to Win vbox as Administrator"
  def copy_to_as_adm(vbox_name,local_path, guest_path)
    init vbox_name
    @machine.upload_file_to_guest_as_admin(local_path, guest_path, false)
  end

  desc "copy_to [vbox name] [local file] [path in vbox]", "Copy local file to Win vbox"
  def copy_to(vbox_name,local_path, guest_path)
    init vbox_name
    @machine.upload_file_to_guest(local_path, guest_path, false)
  end

  desc "copy_from [vbox name] [path in vbox] [local file]", "Copy file from Win vbox to local path"
  def copy_from(vbox_name, guest_path, local_path)
    init vbox_name
    @machine.download_file_from_guest(guest_path, local_path, false)
  end

  desc "cmd [vbox name] [command to execute]", "Run command with cmd.exe in Win vbox"
  def cmd(vbox_name,command)
    init vbox_name

    print @machine.run_command command
    print "\n"
  end

  desc "cmd_adm [vbox name] [command to execute]", "Run command as Administrator with cmd.exe in Win vbox"
  def cmd_as_adm(vbox_name,command)
    init vbox_name

    print @machine.run_command_as_admin command
  end

  private

  def init vbox_name
    @machine = Ievms::WindowsGuest.new vbox_name
  end
end
