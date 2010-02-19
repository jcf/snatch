require 'nokogiri'

class Snatch
  class Clean
    attr_reader :doc, :working_directory

    def initialize(file_name, working_directory = nil)
      @file_name         = file_name
      @working_directory = working_directory || Snatch::PUBLIC_PATH
      @doc               = Nokogiri::XML(File.open(@file_name, 'r'))
    end

    def self.process(html, working_directory = nil)
      instance = new(html, working_directory)
      instance.process
      instance
    end

    def process
      CSS.update(@doc, @working_directory)
      HTML.update(@doc, @working_directory)

      File.open(@file_name, 'w') { |f| f.write @doc.to_xhtml }
    end

	private

	  # Sadly we can't use this as our XSLT won't output valid XHTML
		# def clean_xhtml
		# 	xsl_io = File.open(File.expand_path('../../../xsl/pretty_print.xsl', __FILE__))
		# 	Nokogiri::XSLT(xsl_io).apply_to(@doc)
		# end
  end
end
