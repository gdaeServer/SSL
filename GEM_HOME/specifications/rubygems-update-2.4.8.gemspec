# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "rubygems-update"
  s.version = "2.4.8"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Jim Weirich", "Chad Fowler", "Eric Hodel"]
  s.date = "2015-06-08"
  s.description = "RubyGems is a package management framework for Ruby.\n\nThis gem is an update for the RubyGems software. You must have an\ninstallation of RubyGems before this update can be applied.\n\nSee Gem for information on RubyGems (or `ri Gem`)\n\nTo upgrade to the latest RubyGems, run:\n\n  $ gem update --system  # you might need to be an administrator or root\n\nSee UPGRADING.rdoc for more details and alternative instructions.\n\n-----\n\nIf you don't have RubyGems installed, you can still do it manually:\n\n* Download from: https://rubygems.org/pages/download\n* Unpack into a directory and cd there\n* Install with: ruby setup.rb  # you may need admin/root privilege\n\nFor more details and other options, see:\n\n  ruby setup.rb --help"
  s.email = ["rubygems-developers@rubyforge.org"]
  s.executables = ["update_rubygems"]
  s.extra_rdoc_files = ["CONTRIBUTING.rdoc", "CVE-2013-4287.txt", "CVE-2013-4363.txt", "History.txt", "LICENSE.txt", "MIT.txt", "Manifest.txt", "README.rdoc", "UPGRADING.rdoc", "hide_lib_for_update/note.txt"]
  s.files = ["bin/update_rubygems", "CONTRIBUTING.rdoc", "CVE-2013-4287.txt", "CVE-2013-4363.txt", "History.txt", "LICENSE.txt", "MIT.txt", "Manifest.txt", "README.rdoc", "UPGRADING.rdoc", "hide_lib_for_update/note.txt"]
  s.homepage = "http://rubygems.org"
  s.licenses = ["Ruby", "MIT"]
  s.rdoc_options = ["--main", "README.rdoc", "--title=RubyGems Update Documentation"]
  s.require_paths = ["hide_lib_for_update"]
  s.required_ruby_version = Gem::Requirement.new(">= 1.8.7")
  s.rubygems_version = "1.8.24"
  s.summary = "RubyGems is a package management framework for Ruby"

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<minitest>, ["~> 5.7"])
      s.add_development_dependency(%q<rdoc>, ["~> 4.0"])
      s.add_development_dependency(%q<builder>, ["~> 2.1"])
      s.add_development_dependency(%q<hoe-seattlerb>, ["~> 1.2"])
      s.add_development_dependency(%q<ZenTest>, ["~> 4.5"])
      s.add_development_dependency(%q<rake>, ["~> 0.9.3"])
      s.add_development_dependency(%q<hoe>, ["~> 3.13"])
    else
      s.add_dependency(%q<minitest>, ["~> 5.7"])
      s.add_dependency(%q<rdoc>, ["~> 4.0"])
      s.add_dependency(%q<builder>, ["~> 2.1"])
      s.add_dependency(%q<hoe-seattlerb>, ["~> 1.2"])
      s.add_dependency(%q<ZenTest>, ["~> 4.5"])
      s.add_dependency(%q<rake>, ["~> 0.9.3"])
      s.add_dependency(%q<hoe>, ["~> 3.13"])
    end
  else
    s.add_dependency(%q<minitest>, ["~> 5.7"])
    s.add_dependency(%q<rdoc>, ["~> 4.0"])
    s.add_dependency(%q<builder>, ["~> 2.1"])
    s.add_dependency(%q<hoe-seattlerb>, ["~> 1.2"])
    s.add_dependency(%q<ZenTest>, ["~> 4.5"])
    s.add_dependency(%q<rake>, ["~> 0.9.3"])
    s.add_dependency(%q<hoe>, ["~> 3.13"])
  end
end
