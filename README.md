# ievms-ruby

[![Gem Version](https://badge.fury.io/rb/ievms-ruby.svg)](https://badge.fury.io/rb/ievms-ruby)
[![Code Climate](https://codeclimate.com/github/mipmip/ievms-ruby/badges/gpa.svg)](https://codeclimate.com/github/mipmip/ievms-ruby)
[![Test Coverage](https://codeclimate.com/github/mipmip/ievms-ruby/badges/coverage.svg)](https://codeclimate.com/github/mipmip/ievms-ruby/coverage)
[![Dependency Status](https://gemnasium.com/mipmip/ievms-ruby.svg)](https://gemnasium.com/mipmip/ievms-ruby)


Ruby interface for boxes made by ievms.sh. Use this Library to provision your
IE boxes from https://modern.ie.

Next to [ievms.sh](https://github.com/xdissent/ievms), `ievms-ruby` also works great in combination with [iectrl](https://github.com/xdissent/iectrl).

## WinBoxes supported

![winxp](https://img.shields.io/badge/WinXP-failure-red.svg)
![win7](https://img.shields.io/badge/Win7-success-brightgreen.svg)
![win8](https://img.shields.io/badge/Win8-success-brightgreen.svg)
![win10](https://img.shields.io/badge/Win10-unknown-lightgrey.svg)

## Requirements

* [VirtualBox](https://www.virtualbox.org/wiki/Downloads) >= 5.0.6
* VirtualBox Extension Pack and Guest Additions >= 5.0.6
* Host Machine: OSX or Linux (only tested on OSX 10.9 & 10.10)
* Virtual Machines created by .ievms (only tested with vanilla Win7 machines)

## Features

* Works with Windows 7
* Upload files to guest machine
* Download file from guest machine
* Execute batch file on guest machine
* Execute batch file as admin on guest machine
* Cat file guest machine from cli

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'ievms-ruby'
```
    $ bundle

Or install it yourself as:

    $ gem install ievms-ruby

## Usage

### From CLI
After gem install you can call:

```bash
ievmsrb help
```

to cat a guest file:

```bash
ievmsrb cat "IE9 - Win7" 'C:\Windows\System32\Drivers\Etc\hosts'
```

### As library
Ievms-ruby very usable as provision tool for windows. E.g. for CI. Here's an example
provisioning script using the Gem:

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
      @machine.run_command_as_admin "c:\\ProgramData\\chocolatey\\bin\\choco install -y #{pkg}"
    end
  end
end

provision = ProvisionIE.new
provision.init
provision.install_chocolatey
provision.install_ruby_and_git
```

## TODO 0.1.x first loud release

* Upload files as admin to guest machine
* Test Windows 10
* Execution time out for exec, as option
* Test on Linux guest
* Gitlab CI Example

## BackLog

* Ansible Example
* Jenkins Example

## Contributing

Merge requests are welcome. Specially for XP support. Please submit a new ticket if you want to report an issue.

### Testing

To run the tests you need top fullfil the testing requirements first:

* VirtualBox >= 5.0.4
* "IE9 - Win7" installed by ievms.sh
* Create an new virtual machine called `standbymachine`. Keep the disk size as
  small as possible. It should be turned off.

```
git clone https://github.com/mipmip/ievms-ruby.git
cd ievms-ruby
bundle install
rake
```

### Merge Requests

1. Fork it ( https://github.com/mipmip/ievms-ruby/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Troubleshooting

- If tests fail check if virtualbox guest additions 5.0.6 or higher are
  installed

## Acknowledgements
- ievms - Provider of a platform and methology
- modern.IE - Provider of IE VM images.
- virtualbox - Software for running Virtual Machines
- shields.io - Creates the beautiful Windows Badges


