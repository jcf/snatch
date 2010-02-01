require 'nokogiri'

class Snatch
  class Clean
    attr_reader :doc, :working_directory

    def initialize(file_name, working_directory = nil)
      @file_name         = file_name
      @working_directory = working_directory || Snatch::PUBLIC_PATH
      @doc               = Nokogiri::HTML(File.open(@file_name, 'r'))
    end

    # Convenience method for creating Snatch::Clean with HTML.
    #
    # Returns instance of Snatch::Clean
    def self.process(html, working_directory = nil)
      instance = new(html, working_directory)
      instance.process
      instance
    end

    # Loop through each link with a stylesheet rel attribute and remove
    # dynamic PHP hrefs, replacing with plain CSS paths.
    #
    # Returns link tags
    def process
      @doc.css('link[rel=stylesheet]').each do |stylesheet_node|
        stylesheet_node['href'] = rewrite_href(stylesheet_node['href'])
      end

      return unless @css_path
      File.open(@file_name, 'w') { |f| f.write @doc.to_html }
    end

  private
    def log(*messages)
      width = messages.max(&:size).size
      puts "\e[36;1m#{messages.map(&:inspect).join("\n")}\e[0m"
      puts '=' * width.to_i
    end

    def rewrite_href(href)
      return href unless href.present?
      css_path = href
      matches  = extract_path_components(href)

      if matches.present?
        path = matches.size == 3 ? matches.shift : nil

        file_name = matches.join('-')
        css_path  = File.join(*[path, "#{file_name}.css"].compact)

        mv_stylesheet(href, css_path)
      end

      css_path
    end

    # Look for a match within our stylesheet link href. If it's there
    # reject the original string from MatchData.
    #
    # Returns Array of matches or nil
    def extract_path_components(href)
      m = href.match(%r{^(.+)?stylesheet\.php\?cssid=(\d+)(?:&amp;|&)mediatype=(\w+)})
      m.present? ? m.to_a[1..-1].compact : nil
    end

    def remove_query_params(href)
      href.sub(%r{\.php\?.*?$}, '.php')
    end

    # Convert any number of paths in to absolute paths prepending with
    # the public path (e.g. /Users/jcf/git/static/public/#{path}).
    #
    # Returns an Array of expanded paths
    def expand_paths(*paths)
      paths.map { |path| File.expand_path(File.join(@working_directory, path)) }
    end

    def mv_stylesheet(php_path, css_path)
      php_path, @css_path = *expand_paths(php_path, css_path)
      FileUtils.mv(php_path, @css_path) if File.exist?(php_path)
    end
  end
end
