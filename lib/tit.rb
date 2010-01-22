#!/usr/bin/env ruby

require 'rubygems'
require 'ftools'
require 'nokogiri'
require 'optparse'
require 'rest_client'
require 'time'  # heh.
require 'yaml'

class String
  def wrapped(cols)
    curlen = 0
    split.inject([[]]) do |rows, word|
      if curlen + word.length > cols
        curlen = word.length + 1
        rows << [word]
      else
        curlen += word.length + 1
        rows << (rows.pop << word)
      end
    end.map { |row| row.join(' ') }
  end
end

class Time
  def time_ago_in_words
    t = Time.now
    secs = t - self
    minutes = secs / 60
    hours = minutes / 60
    days = hours / 24
    if hours <= 12  # show a fuzzy time
      if hours > 2
        "#{hours.to_i} hours ago"
      elsif hours > 1
        "about an hour ago"
      elsif minutes > 2
        "#{minutes.to_i} minutes ago"
      elsif minutes > 1
        "about a minute ago"
      else
        "just now"
      end
    elsif days <= 15  # show time ago in days, with time if it was yesterday or today
      if t.day == day
        "today at #{strftime("%X")}"
      elsif t.day - day == 1
        "yesterday at #{strftime("%X")}"
      else
        "#{days.to_i} days ago"
      end
    else  # time in months or years
      months = t.month - month + (t.year - year) * 12
      if months <= 6
        if months == 1
          "last month"
        elsif t.year == year
          "this #{strftime("%B")}"
        else
          "last #{strftime("%B")}"
        end
      else
        if t.year - year == 1
          "last year"
        else
          "#{t.year - year} years ago"
        end
      end
    end
  end
end

=begin rdoc
Why are you reading the documentation, you cunt?
=end
class Tit
  RCFILE = File.join(ENV["HOME"], ".titrc")

  READERS = [:public, :home, :mentions]
  WRITERS = [:update]

  URLS = {
    :public => "statuses/public_timeline.xml",
    :home => "statuses/home_timeline.xml",
    :mentions => "statuses/mentions.xml",
    :update => "statuses/update.xml"
  }

  def initialize
    @username = nil
    @password = nil
    begin
      File.open(RCFILE, "r") do |rc|
        data = YAML.load(rc)
        @username = data["username"]
        @password = data["password"]
      end
    rescue Errno::ENOENT => e
      File.open(RCFILE, "w") do |rc|
        YAML.dump({
                    "username" => "<username>",
                    "password" => "<password>"
                  }, rc)
      end
    end

    if @username.nil? or @username.eql? "<username>" or
        @password.nil? or @password.eql? "<password>"
      puts "Please fill in your username and password in #{RCFILE}"
      exit(-1)
    end

    # set up proxy
    RestClient.proxy = ENV['https_proxy']

    # get terminal width
    @cols = %x[tput cols].to_i
  end
  attr_accessor :opts

  def resource
    RestClient::Resource.new("https://#{@username}:#{@password}@twitter.com/")
  end

  def get_tits(action)
    Nokogiri.XML(resource[URLS[action]].get).xpath("//status").map do |xml|
      {
        :username => xml.at_xpath("./user/name").content,
        :userid => xml.at_xpath("./user/screen_name").content,
        :text => xml.xpath("./text").map { |n| n.content },
        :timestamp => Time.parse(xml.at_xpath("./created_at").content),
        :id => xml.at_xpath("./id").content.to_i,
        :geo => xml.at_xpath("./geo").instance_eval do
          unless children.empty?
            n, e = children[1].content.split.map { |s| s.to_f }
            "#{n.abs}#{n >= 0 ? 'N' : 'S'} #{e.abs}#{e >= 0 ? 'E' : 'W'}"
          end
        end
      }
    end
  end

  def update(payload)
    if payload["status"] == STDIN
      payload["status"] = STDIN.read
    end

    if payload["status"].length > 140
      puts "your status is too long (by #{payload["status"].length - 140} characters)"
      puts "here is what would get posted:"
      payload["status"][0...140].wrapped(@cols - 2).each { |l| puts "  #{l}" }
      exit(-1)
    end

    resource[URLS[:update]].post(payload)
  end

  def show_tit(status)
    person = if status[:userid].eql? @username
               "you"
             else
               "#{status[:username]} (#{status[:userid]})"
             end
    at = status[:timestamp].time_ago_in_words
    if status[:geo].nil?
      puts "#{person} said, #{at}:"
    else
      puts "#{person} said, #{at}, from #{status[:geo]}:"
    end

    status[:text].each do |line|
      line.wrapped(@cols - 2).each { |l| puts "  #{l}" }
    end
    puts ""
  end

  def poll(wait, action, notify)
    tits = {}
    get_tits(action).reverse.each do |status|
      show_tit(status)
      tits[status[:id]] = status
    end
    last_update = Time.now()
    loop do
      print "\r", " " * (s = "Last update was at #{last_update.strftime "%X"}, " +
                         "next update at #{(last_update + wait).strftime "%X"}"
                         print s
                         STDOUT.flush
                         sleep(wait)
                         s.length), "\r"
      begin
        num_tits = get_tits(action).reverse.reject do |status|
          tits.include? status[:id]
        end.each_with_index do |status, i|
          if i == 0
            puts "more updates (at #{Time.now.strftime "%X"}):\n"
          end
          show_tit(status)
          tits[status[:id]] = status
        end.length
        %x[#{notify} '#{num_tits} new tit#{num_tits == 1 ? '' : 's'}!'] unless notify.nil? or num_tits == 0
        last_update = Time.now()
      rescue SocketError, Errno::ENETUNREACH, Errno::ETIMEDOUT, RestClient::Exception => e
        puts "networking error, will try again later"
      end
    end
  end

  def run(options)
    if READERS.include? options[:action]
      if options[:wait].nil?
        get_tits(options[:action]).reverse.each &method(:show_tit)
      else
        poll(options[:wait], options[:action], options[:notify])
      end
    elsif options[:action] == :update
      update options[:payload]
    end
  end

  def error msg
    puts "#{File.basename $0}: #{msg}"
  end

  def abort msg
    error(msg)
    puts @opts
    exit(-1)
  end
end
