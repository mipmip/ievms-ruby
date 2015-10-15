# CLI util ievmsrb

The gem ievms-ruby comes with a CLI program calles ievmsrb. This
utility makes controlling virtual windows machines more easily is they
are setup with ievms.

## Installing ievmsrb
Install the Gem on your system:

    $ gem install ievms-ruby

After installation you can use the `ievmsrb` cli program.

## Usage
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

## Some ievmsrb examples

Display the contents of a guest file.
```bash
$ ievmsrb cat "IE9 - Win7" 'C:\Windows\System32\Drivers\Etc\hosts'
```


Execute a cmd on the guestmachine and show the output
```bash
$ ievmsrb cmd "IE9 - Win7" 'tasklist'
```


Copy a file from the Windows Guest to a local path
```bash
$ ievmsrb copy_from "IE9 - Win7" 'C:\Windows\System32\Drivers\Etc\hosts' ~/Desktop/hosts.win9
```

Turn of the Filewall executing a command as Administator
```bash
$ ievmsrb cmd_adm "IE9 - Win7" 'NetSh Advfirewall set allprofiles state off'
```


Show all current account information
To display the user rights that have been assigned to the account you used to log on to a Windows system, use the whoami command line tool with the /priv switch:
```
ievmsrb cmd "IE9 - Win7" "Whoami /ALL"
```
