class Snatch
  class Clean
    class HTML
      module HrefFixMethods
        def remove_index_html(a)
          a['href'] = a['href'].sub(%r{index\.html?$}, '')
        end

        def replace_absolute(a)
          a['href'] = a['href'].sub(%r{(https?)://#{MARKETING_SITE}/}, '/')
        end

        def encode_mailtos(a)
          if a['href'] =~ /^mailto:(.*)/
            a['href'] = 'mailto:' + url_encode($1)
            a.inner_html = html_encode(a.inner_html)
          end
        end

        def prepend_slash(a)
          a['href'] = a['href'].sub(%r{^/?}, '/') unless a['href'].include?(':')
        end

        def append_slash(a)
          slash_required = (%w(# : .) & a['href'].split(//)).empty?
          a['href'] = a['href'].sub(%r{/?$}, '/') if slash_required
        end
      end

      module SrcFixMethods
        def replace_absolute(link)
          link['src'] = link['src'].sub(%r{(https?)://#{MARKETING_SITE}/}, '/')
        end

        def rewrite_uploads(link)
          link['src'] = link['src'].sub(%r{^#{UPLOADS_DIR}/}, "/#{UPLOADS_DIR}/")
        end
      end

      attr_accessor :doc, :working_directory

      def initialize(doc, working_directory)
        @doc = doc
        @working_directory = working_directory
      end

      def self.update(doc, working_directory)
        new(doc, working_directory).update
      end

      def html_encode(string)
        string.gsub(/./){ |char| "&#x#{char.unpack('U')[0].to_s(16)};" }
      end

      def url_encode(string)
        string.gsub(/./) { |char| '%' + char.unpack('H2' * char.size).join('%').upcase }
      end

      def update
        @doc.css('base, meta[generator]').each { |node| node.remove }

        @doc.search('//comment()').remove

        HrefFixMethods.instance_methods.each do |m|
          @doc.css('a[href]').each { |a| send m, a }
        end

        SrcFixMethods.instance_methods.each do |m|
          @doc.css('[src]').each { |a| send m, a }
        end
      end
    end
  end
end
