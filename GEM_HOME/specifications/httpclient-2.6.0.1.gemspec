# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "httpclient"
  s.version = "2.6.0.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Hiroshi Nakamura"]
  s.date = "2015-01-03"
  s.email = "nahi@ruby-lang.org"
  s.executables = ["httpclient"]
  s.files = ["bin/httpclient"]
  s.homepage = "https://github.com/nahi/httpclient"
  s.licenses = ["ruby"]
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.24"
  s.summary = "gives something like the functionality of libwww-perl (LWP) in Ruby"

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
