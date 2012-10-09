require 'rbconfig'

source :rubygems
gemspec

group :development do
  platform = RbConfig::CONFIG['host_os'] rescue Config::CONFIG['host_os']

  case platform
  when /darwin/
    gem 'rb-fsevent', :require => false
  when /linux/
    gem 'rb-inotify', :require => false
  end
end
