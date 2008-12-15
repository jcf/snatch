#!/usr/bin/env ruby -KU
require "rubygems"
require "hpricot"
require "ftools"
require "fileutils"
require "optparse"
require "uri"

class Crawler
  def initialize(args)

    parse(args)

    sites ||= ['cms.alphasights-001.vm.brightbox.net']
    args.each do |arg|
      sites += [URI.escape(arg.sub(/^(http:|https:)\/\//, ''))]
    end

    @sites = sites
  end

  def run(options={})
    unless sanity_check
      print_usage
      exit
    end

    if options[:test] == true
      @sites.each { |s| replace_php_css(s) }
    else
      wget_sites_to_github(@sites)
    end
  end

  private
  def parse(argv)
    options = {:wget_path => '/usr/local/bin/wget', :git_path => '/usr/local/git/bin/git'}

    argv.options do |opts|
      opts.banner = "Usage: #{File.basename($PROGRAM_NAME)} [OPTIONS] SITE_URI(s)"

      opts.separator ""
      opts.separator "Specific Options:"

      opts.on("-w", "--wget", String,
      "Specify the full path to the wget binary (Must be at least version 1.12)" ) do |opt|
        options[:wget_path] = opts
      end

      opts.on("-g", "--git", String,
      "Specify the full path to the git binary" ) do |opt|
        options[:git_path] = opts
      end

      opts.separator "Common Options:"

      opts.on("-h", "--help",
      "Show this message." ) do
        puts opts
        exit
      end

      begin
        opts.parse!
        @options = options
        @usage = opts
      rescue
        puts opts
        exit
      end
    end
  end

  def print_usage
    $stderr.puts "", @usage
    exit
  end

  def sanity_check
    [@options[:wget_path], @options[:git_path]].each do |binary_path|

      binary_name = File.basename(binary_path)

      unless File.exists?(binary_path)
        $stderr.puts "#{q binary_path} does not exist."
        print "Would you like to search for #{q binary_name} in $PATH? (y/N): "

        if $stdin.gets.downcase.chomp! == 'y'
          @all_results = []

          ENV['PATH'].split(':').each do |search_path|
            if File.exists?(File.expand_path(File.join(search_path, binary_name)))
              @all_results += [File.expand_path(File.join(search_path, binary_name))]
            end
          end # ENV['PATH'].split

          if @all_results.length == 0
            $stderr.puts "Could not find #{q binary_name} in $PATH. Exiting..."
            return false
          else
            $stderr.puts "Found #{@all_results.length} possible result#{@all_results.length == 1 ? '' : 's'} for #{q binary_name}"
            $stderr.puts "Please specify the path manually."
            return false
          end # @all_results.length == 0

          return false
        end # $stdin.gets

        $stderr.puts "Path to #{q binary_name} (#{binary_path}) is invalid. Exiting..."
        return false
      end # unless File.exists?(binary_path)
    end # [@options[:wget_path]...
  end # sanity_check

  def wget_sites_to_github(site_uris=[])
    # site_uris.each { |s| @options[:site_uri] = s; wget(s) && git_push(s) }
    site_uris.each { |site_uri| wget(site_uri) }
  end

  def wget(site_uri)
    puts "Removing any existing local resources for site #{q site_uri}"
    FileUtils.rm_r(site_uri) if File.exists?(site_uri)

    command = "#{@options[:wget_path]} -rk#{'q' unless $VERBOSE} #{sq site_uri}"
    puts "Executing: #{q command}"
    system command
    replace_php_css(site_uri)
    
    git_push
  end

  def replace_php_css(site_uri)
    Dir.glob("#{site_uri}/**/*.html").each do |html_file|
      header "Parsing #{q html_file}" if $VERBOSE

      found_php_stylesheet = false

      html = Hpricot(File.read(html_file))

      (html/'/html/head/link[@rel=stylesheet]').map do |stylesheet_tag|
        pattern = '(.*)(stylesheet)(.*)(cssid)=(.*)&(mediatype)=(.*)'
        matches = stylesheet_tag['href'].match(pattern)

        unless matches.nil?
          found_php_stylesheet = true

          relative_prefix = matches[1]
          if relative_prefix != ''
            new_stylesheet_href = File.join(relative_prefix, "#{matches[4]}-#{matches[5]}_#{matches[6]}-#{matches[7]}.css")
          else
            new_stylesheet_href = "#{matches[4]}-#{matches[5]}_#{matches[6]}-#{matches[7]}.css"
          end

          previous_working_dir = Dir.pwd
          working_directory_for_mv = File.join(Dir.pwd, File.dirname(html_file))

          Dir.chdir(working_directory_for_mv)

          puts "Replacing #{q stylesheet_tag['href']} with #{q new_stylesheet_href}" if $VERBOSE

          FileUtils.mv(stylesheet_tag['href'], new_stylesheet_href) if File.exists?(stylesheet_tag['href'])
          
          stylesheet_tag.set_attribute('href', new_stylesheet_href)

          Dir.chdir(previous_working_dir)
        end
      end
      File.open(html_file, 'w') { |f| f.write html } if found_php_stylesheet
    end
  end

  def git_push
    commands = ["#{@options[:git_path]} rm -r --cached .",
                "#{@options[:git_path]} add .",
                "#{@options[:git_path]} commit -a -m 'Automatic crawl as of #{Time.now.to_s}'",
                "#{@options[:git_path]} push"]
    command = commands.join(" && ")
    puts "Executing: #{q command}"
    system command
  end

  def header(heading, underline_character='=')
    puts
    puts underline_character.to_s * heading.length
    puts heading
    puts underline_character.to_s * heading.length
  end

  def q(string)
    "\"#{string}\""
  end
  def sq(string)
    "'#{string}'"
  end
end

c = Crawler.new(ARGV)
# c.run(:skip_wget => true)
c.run