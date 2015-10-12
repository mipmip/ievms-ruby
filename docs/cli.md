# Ievms-ruby CLI

Then gem ievms-ruby comes with a CLI program calles ievmsrb. This
utility makes controlling virtual windows machines more easily is they
are setup with ievms.


## ievmsrb examples

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

