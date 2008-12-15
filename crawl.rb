#!/usr/bin/env ruby -KU
require "rubygems"
require "hpricot"
require "ftools"
require "fileutils"
require "optparse"

class Crawler
  def initialize(args)

    parse(args)

    sites ||= ['cms.alphasights-001.vm.brightbox.net']
    args.each do |arg|
      sites += [arg.sub(/^(http:|https:)\/\//, '')]
    end

    @sites = sites
  end

  def run
    unless sanity_check
      print_usage
      exit
    end

    wget_sites_to_github(@sites)
  end

  private
  def sanity_check
    [@options[:wget_path], @options[:git_path]].each do |binary_path|
      binary_name = File.basename(binary_path)

      unless File.exists?(binary_path)
        $stderr.puts "\"#{binary_path}\" does not exist."
        print "Would you like to search for \"#{binary_name}\" in $PATH? (y/N): "

        if $stdin.gets.downcase.chomp! == 'y'
          ENV['PATH'].split(':').each do |search_path|

            all_results = []

            if File.exists?(File.join(search_path, binary_name))
              all_results += [File.join(search_path, binary_name)]
            end # if File.exists?(File.join...
          end # ENV['PATH'].split

          if all_results.length == 0
            $stderr.puts "Could not find \"#{binary_name}\" in $PATH. Exiting..."
            return false
          else
            print "Found #{all_results.length}"
            if $stdin.gets.downcase.chomp! == 'y'
              @options[binary_name.to_sym] = found
              puts "Using \"#{found}\" for \"#{binary_name}\""
              return true
            end
          end

          return false
        end # $stdin.gets

        $stderr.puts "Path to \"#{binary_name}\" (#{binary_path}) is invalid. Exiting..."
        return false
      end # unless File.exists?(binary_path)
    end # [@options[:wget_path]...
  end # sanity_check

  def wget_sites_to_github(site_uris=[])
    # site_uris.each { |s| @options[:site_uri] = s; wget(s) && git_push(s) }
    site_uris.each { |s| @options[:site_uri] = s; wget(s) }
  end

  def wget(s)
    command = "#{@options[:wget_path]} -rk#{'q' unless $VERBOSE} '#{s}'"
    puts command
    system command
    fix_php_css
  end

  def git_push(s=@options[:site_uri])
    command = "#{@options[:git_path]} add #{s} && #{@options[:git_path]} commit -m 'Crawl as of #{Time.now.to_s}' && #{@options[:git_path]} push"
    puts(command)
    system command
  end

  def fix_php_css
    html_files = Array.new

    Dir.glob("#{@options[:site_uri]}/**/*.*").each do |f|
      html_files += [File.expand_path(f)] if f =~ /.html/
    end

    html_files.each do |f|
      puts "Parsing #{f}"

      doc = Hpricot(File.read(f))

      (doc/'/html/head/link[@rel=stylesheet]').map do |link|
        pattern = '(.*)(stylesheet)(.*)(cssid)=(.*)&(mediatype)=(.*)'
        m = link['href'].match(pattern)

        unless m.nil? # Files do not match our pattern

          @new_href = "#{m[4]}-#{m[5]}_#{m[6]}-#{m[7]}.css"

          @full_path_to_css = File.expand_path(File.join(f, m[1], @new_href))

          valid_path = File.expand_path(File.join(f, link['href']))
          
          if File.exists?(valid_path)
            File.mv(valid_path, @full_path_to_css)
            link.set_attribute("href", @full_path_to_css)
          else
            $stderr.puts "\"#{valid_path}\" does not exist. File referenced in #{f}"
          end
        end
      end

      File.open(f, 'w') {|f| f.write(doc) }
    end
  end

  def parse(argv)
    options = {:wget_path => '/usr/local/bin/wget', :git_path => '/usr/local/git/bin/git'}

    argv.options do |opts|
      opts.banner = "Usage: #{File.basename($PROGRAM_NAME)} [OPTIONS] SITE_URI(s)"

      opts.separator ""
      opts.separator "Specific Options:"

      opts.on( "-w", "--wget", String,
      "Full path to the wget binary (Must be at least version 1.12)" ) do |opt|
        options[:wget_path] = opts
      end

      opts.on( "-g", "--git", String,
      "Full path to the git binary" ) do |opt|
        options[:git_path] = opts
      end

      opts.separator "Common Options:"

      opts.on( "-h", "--help",
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
end

c = Crawler.new(ARGV)
c.run
# c.wget
# c.git_push
# c.sanity_check