class Snatch
  class Clean
    class CSS
      attr_accessor :doc, :working_directory

      def initialize(doc, working_directory)
        self.doc               = doc
        self.working_directory = working_directory
      end

      def self.update(nokogiri_doc, working_directory = nil)
        new(nokogiri_doc, working_directory).update
      end

      def update
        doc.css('link[rel=stylesheet]').each do |stylesheet_node|
          stylesheet_node['href'] = rewrite_href(stylesheet_node['href'])
        end
        doc
      end

      private

      def extract_path_components(href)
        m = href.match(%r{^(.+)?stylesheet\.php\?cssid=(\d+)(?:&amp;|&)mediatype=(\w+)})
        m.nil? ? nil : m.to_a[1..-1].compact
      end

      def expand_paths(*paths)
        paths.map { |path| File.expand_path(File.join(@working_directory, path)) }
      end

      def mv_stylesheet(php_path, css_path)
        php_path, css_path = *expand_paths(php_path, css_path)
        FileUtils.mv(php_path, css_path) if File.exist?(php_path)
      end

      def rewrite_href(href)
        return href if href.empty?
        css_path = href
        matches  = extract_path_components(href)

        unless matches.nil?
          path = matches.size == 3 ? matches.shift : nil

          file_name = matches.join('-')
          css_path  = File.join(*[path, "#{file_name}.css"].compact)

          mv_stylesheet(href, css_path)
        end

        css_path
      end
    end
  end
end
