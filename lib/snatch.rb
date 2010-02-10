$LOAD_PATH.unshift(File.dirname(__FILE__))

require "#{File.dirname(__FILE__)}/extensions"
require 'snatch/clean'

class Snatch
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

  def initialize(url = nil)
    @url = url || 'www.google.com'
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
      FileUtils.rm_rf(pathname.to_s) unless RAILS_PUBLIC_ASSETS.include?(pathname.expand_path("#{RAILS_ROOT}/public").to_s)
    end
  end

  def download_files
    puts "Downloading #{@url.quote}"
    _wget "-P #{PUBLIC_PATH} -nH -rkq #{@url.quote}"
  end

  def process_lame_cms_files
    Dir.glob("#{PUBLIC_PATH}/**/*.html").each do |file|
      Clean.process(file, File.dirname(file))
    end
  end

  def git_push
    git :add, "-A public"
    git :commit, "-q -m 'Automatic snatch'"
    git :push, :silent => true
  end
end
