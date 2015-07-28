# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "bson_ext"
  s.version = "1.12.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Emily Stolfo", "Durran Jordan", "Gary Murakami", "Tyler Brock", "Brandon Black"]
  s.date = "2015-07-20"
  s.description = "C extensions to accelerate the Ruby BSON serialization. For more information about BSON, see http://bsonspec.org.  For information about MongoDB, see http://www.mongodb.org."
  s.email = "mongodb-dev@googlegroups.com"
  s.extensions = ["ext/cbson/extconf.rb"]
  s.files = ["ext/cbson/extconf.rb"]
  s.homepage = "http://www.mongodb.org"
  s.licenses = ["Apache License Version 2.0"]
  s.require_paths = ["ext/bson_ext"]
  s.rubyforge_project = "bson_ext"
  s.rubygems_version = "1.8.24"
  s.summary = "C extensions for Ruby BSON."

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<bson>, ["~> 1.12.1"])
    else
      s.add_dependency(%q<bson>, ["~> 1.12.1"])
    end
  else
    s.add_dependency(%q<bson>, ["~> 1.12.1"])
  end
end
