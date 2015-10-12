# Ievms-ruby Library

Use ievms-ruby as library to create provisioning scripts for ievms
windows boxes. To examplain how to use ievms-ruby we have created some
example scripts. But first you need to know how to use ievms-ruby in
your project.

## Install ievms-ruby gem

Add this line to your application's Gemfile:

```ruby
gem 'ievms-ruby'
```

run `bundle install` or `bunde install --path vendor`. If you're
creating a standalone executable put these lines at on top of your script:

```ruby
#!/usr/bin/env ruby

require 'rubygems'
require 'bundler/setup'
require 'ievms/windows_guest'
```

Now you can use the ievms-ruby API. Have a look at the
[provisioning examples](provisioning_examples/) how.

