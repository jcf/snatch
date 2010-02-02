$LOAD_PATH.unshift(File.dirname(__FILE__))

require "#{File.dirname(__FILE__)}/extensions"
require 'snatch/clean'

class Snatch
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
  
  def self.clean
    new.send(:convert_dynamic_stylesheets)
  end
  
  def self.push
    new.send(:git_push)
  end

  def fetch
    download_files &&
    convert_dynamic_stylesheets &&
    git_push
  end

private

  def log(message)
    bang = "\e[36;40;1m=>\e[0m"
    puts "#{bang} #{message}"
  end

  def which(name)
    @which ||= {}
    return @which[name] unless @which[name].nil?
    path = `which #{name}`.strip
    @which[name] = path
  end

  def wget(arguments = nil)
    wget_path = which :wget
    log "#{wget_path} #{arguments}"
    %x{#{wget_path} #{arguments}}
  end

  def git(command, *args)
    options   = args.last.is_a?(Hash) ? args.pop : {}
    arguments = args.join(' ')
    redirect  = ' > /dev/null' if options[:silent]
    git_path  = which :git
    log "#{git_path} #{command} #{arguments}#{redirect}"
    %x(#{git_path} #{command} #{arguments}#{redirect})
  end

  def download_files
    puts "Downloading #{@url.quote}"
    wget "-P #{PUBLIC_PATH} -nH -rkq #{@url.quote}"
  end

  def convert_dynamic_stylesheets
    Dir.glob("#{PUBLIC_PATH}/**/*.html").each do |file|
      Clean.process(file, File.dirname(file))
    end
  end

  def files_to_remove
    Dir.glob(File.join(PUBLIC_PATH, '**/*')).reject { |path| path =~ %r{public/packaged/} }
  end

  def git_push
    git :rm, "-rq --cached #{files_to_remove}"
    git :add, "public"
    git :commit, "-q -m 'Automatic snatch'"
    git :push, :silent => true
  end
end
