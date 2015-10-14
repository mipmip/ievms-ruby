# ievms-ruby

[![Gem Version](https://badge.fury.io/rb/ievms-ruby.svg)](https://badge.fury.io/rb/ievms-ruby)
[![Code Climate](https://codeclimate.com/github/mipmip/ievms-ruby/badges/gpa.svg)](https://codeclimate.com/github/mipmip/ievms-ruby)
[![Test Coverage](https://codeclimate.com/github/mipmip/ievms-ruby/badges/coverage.svg)](https://codeclimate.com/github/mipmip/ievms-ruby/coverage)
[![Dependency Status](https://gemnasium.com/mipmip/ievms-ruby.svg)](https://gemnasium.com/mipmip/ievms-ruby)
[![Inline docs](http://inch-ci.org/github/mipmip/ievms-ruby.svg?branch=master)](http://inch-ci.org/github/mipmip/ievms-ruby)

Ruby interface for boxes made by ievms.sh. Use this Library to provision your
IE boxes from https://modern.ie.

Next to [ievms.sh](https://github.com/xdissent/ievms), `ievms-ruby` also works great in combination with [iectrl](https://github.com/xdissent/iectrl).

## WinBoxes supported

![winxp](https://img.shields.io/badge/WinXP-failure-red.svg)
![winvista](https://img.shields.io/badge/WinVista-failure-red.svg)
![win7](https://img.shields.io/badge/Win7-success-brightgreen.svg)
![win8](https://img.shields.io/badge/Win8-success-brightgreen.svg)
![win10](https://img.shields.io/badge/Win10-unknown-lightgrey.svg)

## Features

* Upload and download files from guest machine
* Execute cmd.exe and powershell commands on guest machine
* Execute cmd.exe and powershell commands on guest machine as admin
* Shortcut commands for Windows guest like `cat`, `ps`, `reboot` and `shutdown`
* To be used as CLI utility or as library in a ruby script.

## Requirements

* Host Machine: OSX or Linux (only tested on OSX 10.9 & 10.10)
* [VirtualBox](https://www.virtualbox.org/wiki/Downloads) >= 5.0.6
* VirtualBox Extension Pack and Guest Additions >= 5.0.6
* Windows Machines created by [ievms](https://github.com/xdissent/ievms)

### Recommended
* [iectrl](https://github.com/xdissent/iectrl), cli interface for simple
 ievms admin commands

## Usage

### As library
Use Ievms-ruby in provisioning scripts for windows E.g. for Gitlab CI
or Jenkins integration. There are provisioning example's located in the
[ievms-ruby library documentation](http://mipmip.github.io/ievms-ruby/library/).

### From CLI
Install the Gem on your system:

    $ gem install ievms-ruby

After installation you can use the `ievmsrb` cli program.

Here's the output of `ievmsrb help`

```bash
$ ievmsrb help

Commands:
  ievmsrb cat [vbox name] [file path]                             # cat file from path in Win vbox
  ievmsrb cmd [vbox name] [command to execute]                    # Run command with cmd.exe in Win vbox
  ievmsrb cmd_adm [vbox name] [command to execute]                # Run command as Administrator with cmd.exe in Win vbox
  ievmsrb copy_from [vbox name] [path in vbox] [local file]       # Copy file from Win vbox to local path
  ievmsrb copy_to [vbox name] [local file] [path in vbox]         # Copy local file to Win vbox
  ievmsrb copy_to_as_adm [vbox name] [local file] [path in vbox]  # Copy local file to Win vbox as Administrator
  ievmsrb help [COMMAND]                                          # Describe available commands or one specific command
  ievmsrb ps [vbox name]                                          # Show running tasks in Win vbox
  ievmsrb reboot [vbox name]                                      # Reboot Win box
  ievmsrb shutdown [vbox name]                                    # Shutdown Win vbox
```

Read the docs for more info about [ievms-ruby CLI usage](http://mipmip.github.io/ievms-ruby/cli/).

## Contributing
Please submit a new ticket if you want to report an issue.
Merge requests are welcome. See issues with `Help  Wanted` label.

### Testing
To run the tests you need to fullfil the testing requirements first:

* Install VirtualBox >= 5.0.4 at time of writing 5.0.6

* "IE9 - Win7" installed by ievms.sh and make sure its running

* [iectrl](https://github.com/xdissent/iectrl), cli interface for simple

```bash
$ npm install iectrl
$ echo 'PATH="$HOME/node_modules/.bin:$PATH"' >> ~/.profile
$ source ~/.Provider
```

* Create an new virtual machine called `standbymachine`. Keep the disk size as
  small as possible. It should be turned off.

```bash
VBoxManage createvm --name standbymachine --register```

* clone ievms-ruby
```
git clone https://github.com/mipmip/ievms-ruby.git
cd ievms-ruby
bundle install
bundle exec rake
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
