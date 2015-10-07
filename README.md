# ievms-ruby

Ruby interface for boxes made by ievms.sh
(http://xdissent.github.com/ievms). Use this Library to provision your
IE boxes from https://modern.ie.

## Requirements

* VirtualBox >= 5.0.4
* VirtualBox Extension Pack and Guest Additions >= 5.0.4
* Host Machine: OSX or Linux (only tested on OSX 10.9 & 10.10)
* Virtual Machines created by .ievms (only tested with a vanilla "IE9 -
  Win7" machine

## Working

* Works with Windows 7
* Upload files to guest machine
* Execute batch file on guest machine
* Execute batch file as admin on guest machine

## TODO 0.1

* upload files as admin to guest machine
* more IE platforms
* more Win platforms
* Use as CLI
* Documentation
* provisioning example
* Rubycop

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'ievms-ruby'
```
    $ bundle

Or install it yourself as:

    $ gem install ievms-ruby

## Usage
Here's an example provising script using the Gem:

```
TODO
```

## Contributing

1. Fork it ( https://github.com/mipmip/ievms-ruby/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
