# Provisioning examples

Here you can find usable example provisioning scripts.

## Auto install Chocolatey and git-for-windows

provisioning script using the Gem. It installs [Chocolatey](https://chocolatey.org), Ruby, and [git-for-windows](https://git-for-windows.github.io) without user interaction needed.


```ruby
#!/usr/bin/env ruby
require 'rubygems'
require 'bundler/setup'
require 'ievms/windows_guest'

class ProvisionIE

  # Create interface for the 'IE9 - Win7' virtual box
  def init
    @machine = Ievms::WindowsGuest.new 'IE9 - Win7'
  end

  # Install the choco package manager (APT for Windows)
  def install_chocolatey
    print "Installing Chocolatey\n"
    choco_install_cmd = '@powershell -NoProfile -ExecutionPolicy unrestricted -Command "iex ((new-object net.webclient).DownloadString(\'https://chocolatey.org/install.ps1\'))" && SET PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin '
    @machine.run_command_as_admin(choco_install_cmd)
  end

  # Install ruby and git stuff, the reason why we wrote ievms-ruby
  def install_ruby_and_git
    %w( ruby msysgit ).each do |pkg|
      @machine.run_command_as_admin "c:\\ProgramData\\chocolatey\\bin\\choco "\
        "install -y #{pkg}"
    end
  end
end

provision = ProvisionIE.new
provision.init
provision.install_chocolatey
provision.install_ruby_and_git
```
