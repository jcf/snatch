$LOAD_PATH.unshift(File.dirname(__FILE__))

require "extensions"
require 'snatch/clean'
require 'snatch/clean/html'
require 'snatch/clean/css'

class Snatch
  CLEAR      = "\e[0m"
  BOLD       = "\e[1m"
  RED        = "\e[31m"
  YELLOW     = "\e[33m"
  GREEN      = "\e[32m"
  CYAN       = "\e[36m"
  WHITE      = "\e[37m"

  RAILS_ROOT = Dir.pwd unless defined?(RAILS_ROOT)
  RAILS_PUBLIC_ASSETS  = [
    '404.html',
    '422.html',
    '500.html',
    'favicon.ico',
    'iepngfix.htc',
    'images',
    'javascripts',
    'open-flash-chart.swf',
    'packaged',
    'robots.txt',
    'stylesheets'
  ].map { |file_name| File.expand_path("#{RAILS_ROOT}/public/#{file_name}") }
  PUBLIC_PATH = File.expand_path("#{Dir.pwd}/public")

  MARKETING_SITE = 'cms.alphasights-002.vm.brightbox.net'
  UPLOADS_DIR = 'uploads'

  def initialize(url = nil)
    @url = url || MARKETING_SITE
  end

  def self.fetch(url = nil)
    new(url).fetch
  end

  def self.wget
    new.send(:download_files)
  end

	def wget
		download_files
	end

  def self.clean
    new.send(:process_lame_cms_files)
  end

	def clean
		process_lame_cms_files
	end

  def self.push
    new.send(:git_push)
  end

	def push
		git_push
	end

  def fetch
    remove_cms_files
    download_files &&
    	convert_dynamic_stylesheets &&
    	git_push
  end

	private

  def log(message)
    bang = "\e[36;40;1m=>\e[0m"
    puts "#{bang} #{message[0..50]}..."
  end

  def _wget(arguments = nil)
    log "wget #{arguments}"
    %x{wget #{arguments}}
  end

  def git(command, *args)
    options   = args.last.is_a?(Hash) ? args.pop : {}
    arguments = args.join(' ')
    redirect  = ' > /dev/null' if options[:silent]
    log "git #{command} #{arguments}#{redirect}"
    %x(git #{command} #{arguments}#{redirect})
  end

  def remove_cms_files
    glob_path = File.expand_path("#{RAILS_ROOT}/public") + '/*'
    Pathname.glob(glob_path) do |pathname|
      public_path = pathname.expand_path("#{RAILS_ROOT}/public").to_s
      FileUtils.rm_rf(pathname.to_s) unless RAILS_PUBLIC_ASSETS.include?(public_path)
    end
  end

  def download_files
    puts "Downloading #{@url.quote}"
    _wget "-P #{PUBLIC_PATH} -nH -rq #{@url.quote}"
  end

  def process_lame_cms_files
    cms_html_files = Dir.glob("#{PUBLIC_PATH}/**/*.html") - RAILS_PUBLIC_ASSETS
    cms_html_files.each do |file|
			puts "#{GREEN}Cleaning #{file}#{CLEAR}"
      Clean.process(file, File.dirname(file))
    end
  end

  def git_push
    git :add, "-A public"
    git :commit, "-q -m 'Automatic snatch'"
    git :push, :silent => true
  end
end

