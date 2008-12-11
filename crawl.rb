#!/usr/bin/env ruby -KU
require "rubygems"
require "hpricot"
require "ftools"

class Crawler
  def initialize(site_uri='cms.alphasights-001.vm.brightbox.net',
                 wget_path='/usr/local/bin/wget')
    @site_uri = site_uri
    @wget_path = wget_path
    sanity_check
  end
  
  def sanity_check
    if @wget_path == '' && %x(which wget).length == 0
      raise "wget not in $PATH. Please specify path to wget manually.\n\nCrawler.new('site_uri', '/path/to/wget')"
    end
    if @git_path == '' && %x(which git).length == 0
      raise "git not in $PATH. Please specify path to git manually.\n\nCrawler.new('site_uri', '/path/to/git')"
    end
  end
  
  def wget_sites(site_uris=[])
    site_uris.each { |s| wget(s) }
  end
  
  def wget(s=@site_uri)
    command = "#{@wget_path} -rk#{'q' unless $VERBOSE} '#{s}'"
    $stdout.puts(command)
    system command
    fix_php_css
  end
  
  def fix_php_css
    html_files = Array.new
    
    Dir.glob("#{@site_uri}/**/*.*").each do |f|
       html_files += [File.expand_path(f)] if f =~ /.html/
    end
    
    html_files.each do |f|
      $stdout.puts "Parsing #{f}"
      
      doc = Hpricot(File.read(f))
      
      (doc/'/html/head/link[@rel=stylesheet]').map do |link|
        pattern = '(.*)(stylesheet)(.*)(cssid)=(.*)&(mediatype)=(.*)'
        new_link = link['href'].match(pattern)
        
        return true if new_link.nil? # Files do not match our pattern. Give up.
        
        @new_href = "#{new_link[1]}#{new_link[4]}-#{new_link[5]}_#{new_link[6]}-#{new_link[7]}.css"
        
        File.copy(File.join(File.dirname(f), link['href']), File.join(File.dirname(f), @new_href))
        link.set_attribute("href", @new_href)
      end
      
      File.open(f, 'w') {|f| f.write(doc) }
    end
  end
  
  def git_push(s=@site_uri)
    command = "#{@git_path} add #{s} && git commit -m 'Crawl as of #{Time.now.strftime}' && git push"
    $stdout.puts(command)
    system command
  end
  
end

c = Crawler.new()
c.wget