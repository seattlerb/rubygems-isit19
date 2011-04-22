require 'rubygems'
require 'rubygems/remote_fetcher'
require 'json'

##
# Utilities for determining if a Gem::Specification is ruby 1.9 ready.  Based
# on http://isitruby19.com

class IsIt19

  ##
  # This version of rubygems-isit19

  VERSION = '1.0'

  ##
  # Comments for this gem

  attr_reader :comments

  ##
  # The gemspec

  attr_reader :spec

  ##
  # Downloads comments for +spec+ from http://isitruby19.com

  def initialize(spec)
    @spec = spec

    url = URI.parse "http://isitruby19.com/#{@spec.name}/comments.json"

    json = Gem::RemoteFetcher.fetcher.fetch_path url
    comments = JSON.parse json

    comments.map! do |comment|
      begin
        comment['comment']['version'] =
          Gem::Version.new comment['comment']['version']
        comment['comment']
      rescue ArgumentError # bad data from isitruby19.com
        next
      end
    end

    comments.compact!

    @comments = comments.sort_by do |comment|
      works = comment['works_for_me'] ? 1 : 0
      [comment['version'], works, comment['name']]
    end.reverse
  end

  ##
  # Strict check for this version

  def one_nine?
    @comments.any? do |comment|
      comment['version'] == @spec.version and comment['works_for_me']
    end
  end

  ##
  # Returns a comment from the latest version that worked with 1.9

  def maybe_one_nine?
    @comments.first do |comment|
      comment['works_for_me']
    end
  end

  ##
  # Returns a percentage of people saying +version+ worked for them

  def percent(version = @spec.version)
    matching = @comments.select do |comment|
      comment['version'] == version
    end

    works = matching.select do |comment| comment['works_for_me'] end.length

    percent = (works / matching.length.to_f * 100)
    percent = 0   if percent.nan?
    percent = 100 if percent > 100

    "%2.0f%%" % percent
  end

  ##
  # URL of this gem on http://isitruby19.com

  def url
    "http://isitruby19.com/#{spec.name}"
  end

end

