# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run the gemspec command
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{tit}
  s.version = "2.1.7"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Leif Walsh", "Parker Moore"]
  s.date = %q{2011-09-19}
  s.default_executable = %q{tit}
  s.description = %q{a stupid fucking twitter client}
  s.email = [%q{leif.walsh@gmail.com}, %q{parkrmoore@gmail.com}]
  s.executables = ["tit"]
  s.extra_rdoc_files = [
     "ChangeLog.markdown",
     "LICENSE",
     "README.markdown"
  ]
  s.files = [
    ".gitignore",
     "ChangeLog.markdown",
     "LICENSE",
     "README.markdown",
     "Rakefile",
     "VERSION.yml",
     "bin/tit",
     "lib/tit.rb",
     "tit.gemspec"
  ]
  s.homepage = %q{http://github.com/adlaiff6/tit}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.5}
  s.summary = %q{stupid fucking twitter client}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<nokogiri>, [">= 0"])
      s.add_runtime_dependency(%q<oauth>, [">= 0"])
      s.add_runtime_dependency(%q<htmlentities>, [">= 0"])
    else
      s.add_dependency(%q<nokogiri>, [">= 0"])
      s.add_dependency(%q<oauth>, [">= 0"])
      s.add_dependency(%q<htmlentities>, [">= 0"])
    end
  else
    s.add_dependency(%q<nokogiri>, [">= 0"])
    s.add_dependency(%q<oauth>, [">= 0"])
    s.add_dependency(%q<htmlentities>, [">= 0"])
  end
end
