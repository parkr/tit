#!/usr/bin/env ruby -wKU

require 'fileutils'
require 'yaml'

if(ARGV.length != 2)
  puts "Need version numbers: x.x.x x.x.x"
  exit(-1)
else
  version = {
    :old => ARGV[0],
    :new => ARGV[1]
  }
end

File.open("package.sh", "w") do |pkg|
  add = "#! /bin/bash\n\ngem build tit.gemspec\ngem install -l tit-#{version[:new]}.gem\n"
  pkg.write(add)
end

File.open("tag.sh", "w") do |tag|
  add = "#! /bin/bash\n\ngit tag -a v#{version[:new]} -m v#{version[:new]}\n"
  tag.write(add)
end

File.open("tit.gemspec2", "w+") do |spec|
  contents = IO.read("tit.gemspec")
  contents.gsub!("version = \"#{version[:old]}\"", "version = \"#{version[:new]}\"")
  spec.write(contents)
  FileUtils.mv "tit.gemspec2", "tit.gemspec"
end

File.open("lib/tit.rb2", "w+") do |spec|
  contents = IO.read("lib/tit.rb")
  sections = version[:old].split(".")
  old = [sections[0].to_i, sections[2].to_i, sections[3].to_i]
  sections = version[:new].split(".")
  neew = [sections[0].to_i, sections[2].to_i, sections[3].to_i]
  contents.gsub!("VERSION = \"#{old.to_s}\"", "VERSION = \"#{neew.to_s}\"")
  spec.write(contents)
  FileUtils.mv "lib/tit.rb2", "lib/tit.rb"
end

File.open("VERSION.yml", "w") do |ver|
  sections = version[:new].split(".")
  YAML::dump({
    :major => sections[0].to_i,
    :minor => sections[1].to_i,
    :patch => sections[2].to_i
  }, ver)
end

File.open("ChangeLog.markdown2", "w") do |chg|
  contents = IO.read("ChangeLog.markdown")
  new_stuff = "# tit #{version[:new]} #{Date.today.to_s}\n\n* \n\n#{contents.strip}"
  chg.write(new_stuff)
  FileUtils.mv "ChangeLog.markdown2", "ChangeLog.markdown"
end