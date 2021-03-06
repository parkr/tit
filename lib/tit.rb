#!/usr/bin/env ruby

require 'rubygems'
require 'fileutils'
require 'nokogiri'
require 'oauth'
require 'time'  # heh.
require 'yaml'
require 'htmlentities' # hate those &lt;3

class String
  URI_REGEX = %r"((?:(?:[^ :/?#]+):)(?://(?:[^ /?#]*))(?:[^ ?#]*)(?:\?(?:[^ #]*))?(?:#(?:[^ ]*))?)"
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
  def replace_with_expanded_url! (expanded)
    replace(replace_with_expanded_url(expanded))
  end
  def replace_with_expanded_url(expanded)
    replace_uris(/http:\/\/t.co\/[a-zA-Z0-9]{1,8}$/i, expanded)
  end
  def replace_uris(old, newt)
    split(URI_REGEX).collect do |s|
      if s =~ URI_REGEX
        s.gsub(old, newt.join)
      else
        s
      end
    end.join
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
  VERSION = [2, 1, 7]
  
  RCFILE = File.join(ENV["HOME"], ".titrc")
  RTFILE = File.join(ENV["HOME"], ".titrt")
  ATFILE = File.join(ENV["HOME"], ".titat")

  READERS = [:public, :home, :mentions, :user_timeline, :direct_messages]
  WRITERS = [:update, :new_direct_message]

  URLS = {
    :public => "/statuses/public_timeline.xml",
    :home => "/statuses/home_timeline.xml",
    :mentions => "/statuses/mentions.xml",
    :user_timeline => "/statuses/user_timeline.xml",
    :update => "/statuses/update.xml",
    :direct_messages => "/direct_messages.xml",
    :new_direct_message => "/direct_messages/new.xml"
  }

  KEY = "K2OOlWbQodfm4YV9Fmeg"
  SECRET = "B1HuqK8zoDDLboRAWPqlHTFbLVdkQfquzoUC1MkuM"

  def initialize
    @consumer = OAuth::Consumer.new(KEY, SECRET,
                                    { :site => "https://twitter.com" })
    # get terminal width
    @cols = %x[tput cols].to_i
    # get status count
    @prefs = YAML.load_file(RCFILE)
  end
  attr_accessor :opts

  def get_access
    begin
      @access_token = File.open(ATFILE, "r") do |at|
        params = YAML.load(at)
        @userid = params[:screen_name]
        OAuth::AccessToken.from_hash(@consumer, params)
      end
    rescue Errno::ENOENT => e
      request_token = @consumer.get_request_token
      File.open(RTFILE, "w") do |rt|
        YAML.dump(request_token.params, rt)
      end
      File.open(RCFILE, "w") do |rc|
        YAML.dump({:count => 10, :tco => true}, rc)
      end
      tuts "Please visit '#{request_token.authorize_url}'."
      tuts "When you finish, provide your pin with `tit --pin PIN'"
      exit(0)
    end
  end

  def use_pin(pin)
    begin
      request_token = File.open(RTFILE, "r") do |rt|
        params = YAML.load(rt)
        OAuth::RequestToken.from_hash(@consumer, params)
      end
    rescue Errno::ENOENT => e
      tuts "You lost your old token, gotta try again."
      get_access
    end
    begin
      @access_token = request_token.get_access_token(:oauth_verifier => pin)
    rescue OAuth::Unauthorized => e
      tuts "Sorry, that's an old pin."
      File.delete(RTFILE)
      get_access
    end
    File.open(ATFILE, "w") do |at|
      YAML.dump(@access_token.params, at)
    end
    File.delete(RTFILE)
    tuts "Thanks, you're done with authentication."
    tuts "Keep #{ATFILE} secure and intact.  If it's compromised, I can't " +
      "revoke your token."
  end

  def get_tits(action, payload)
    # Build the API Endpoint
    api_endpoint = URLS[action]
    if(action == :user_timeline and not payload.nil?)
      api_endpoint.concat("?screen_name=".concat(payload['user'])).concat("&count=#{@prefs[:count]}")
    else
      api_endpoint.concat("?count=#{@prefs[:count]}")
    end
    api_endpoint.concat("&include_entities=true")
    
    # I'll use this to decode HTML entities.
    coder = HTMLEntities.new
    
    # Parse XML
    xmlbody = @access_token.get(api_endpoint).body
    
    # Errors
    Nokogiri.XML(xmlbody).xpath("//errors").map do |xml|
      if xml.at_xpath("./error").content == "This application is not allowed to access or delete your direct messages"
        abort("Your OAuth key is not authorized for direct messaging.\nDelete #{TITAT} and run tit without arguments to reauthorize.")
      end
    end
    
    # no errors - get tits
    if action != :direct_messages
      Nokogiri.XML(xmlbody).xpath("//status").map do |xml|
        {
          :username => xml.at_xpath("./user/name").content,
          :userid => xml.at_xpath("./user/screen_name").content,
          :text => xml.xpath("./text").map do |n|
            txt = coder.decode(n.content)
            if not xml.xpath("./entities/urls").nil?
              xml.xpath("./entities/urls/url").map do |url|
                txt.replace_with_expanded_url!(url.xpath("./expanded_url").map { |expurl| expurl.content }) unless @prefs[:tco].eql?("TRUE")
              end
            end
            txt
          end,
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
    else
      # get the dms
      Nokogiri.XML(xmlbody).xpath("//direct_message").map do |xml|
        {
          :username => xml.at_xpath("./sender/name").content,
          :userid => xml.at_xpath("./sender_screen_name").content,
          :text => xml.xpath("./text").map {|n| coder.decode(n.content)},
          :timestamp => Time.parse(xml.at_xpath("./created_at").content),
          :id => xml.at_xpath("./id").content.to_i,
        }
      end
    end
  end

  def update(payload)
    if payload["status"] == STDIN
      payload["status"] = STDIN.read
    end

    # Count URLs only as t.co length, not full length.

    if payload["status"].length > 140
      tuts "your status is too long (by #{payload["status"].length - 140} characters)"
      tuts "here is what would get posted:"
      payload["status"][0...140].wrapped(@cols - 2).each { |l| puts "  #{l}" }
      exit(-1)
    end

    @access_token.post(URLS[:update], payload)
  end
  
  def send_dm(payload)
    # Count URLs only as t.co length, not full length.
    if payload["text"].length > 140
      tuts "your message is too long (by #{payload["text"].length - 140} characters)"
      tuts "here is what would get posted:"
      payload["text"][0...140].wrapped(@cols - 2).each { |l| puts "  #{l}" }
      exit(-1)
    end
    
    response = @access_token.post(URLS[:new_direct_message], payload)
    
    # Check the response for errors
    Nokogiri.XML(response).xpath("//hash").map do |xml|
        if xml.at_xpath("./error")
          abort("you cannot send a dm to someone who doesn't follow you")
        end
    end
  end

  def show_tit(status)
    person = if status[:userid].eql? @userid
               "you"
             else
               "#{status[:username]} (#{status[:userid]})"
             end
    at = status[:timestamp].time_ago_in_words
    if status[:geo].nil?
      tuts "#{person} said, #{at}:"
    else
      tuts "#{person} said, #{at}, from #{status[:geo]}:"
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
                         "next update at #{(Time.now + wait).strftime "%X"}"
                         print s
                         STDOUT.flush
                         sleep(wait)
                         s.length), "\r"
      begin
        num_tits = get_tits(action).reverse.reject do |status|
          tits.include? status[:id]
        end.each_with_index do |status, i|
          if i == 0
            tuts "more updates (at #{Time.now.strftime "%X"}):"
            puts ""
          end
          show_tit(status)
          tits[status[:id]] = status
        end.length
        %x[#{notify} '#{num_tits} new tit#{num_tits == 1 ? '' : 's'}!'] unless notify.nil? or num_tits == 0
        last_update = Time.now()
      rescue SocketError, Errno::ENETUNREACH, Errno::ETIMEDOUT, NoMethodError => e
        tuts "networking error, will try again later"
      end
    end
  end

  def run(options)
    if READERS.include? options[:action]
      if options[:wait].nil?
        get_tits(options[:action], options[:payload]).reverse.each &method(:show_tit)
      else
        poll(options[:wait], options[:action], options[:notify])
      end
    elsif options[:action] == :update
      update options[:payload]
    elsif options[:action] == :new_direct_message
      send_dm options[:payload]
    end
  end
  
  def update_count(count)
    @prefs[:count] = count.to_i
    @prefs["count"] = count.to_i
    File.open(RCFILE, "w") do |rc|
      YAML.dump(@prefs, rc)
    end
    exit(0)
  end
  
  def update_tco(tco)
    @prefs[:tco] = tco
    @prefs["tco"] = tco
    File.open(RCFILE, "w") do |rc|
      YAML.dump(@prefs, rc)
    end
    exit(0)
  end

  def tuts(*strs)
    strs.each { |s| puts s.to_s.wrapped(@cols) }
  end

  def error(msg)
    tuts "#{File.basename $0}: #{msg}"
  end

  def abort(msg)
    error(msg)
    puts @opts
    exit(-1)
  end
end
