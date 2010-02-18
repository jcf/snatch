$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'snatch'
require 'spec'
require 'spec/autorun'

Dir[File.dirname(__FILE__) + "/support/**/*.rb"].each { |f| require f }

Spec::Runner.configure do |config|
  
end

def fix_node(method, xhtml)
  node = Nokogiri::XML(xhtml).children.first
  subject.send method, node
  block_given? ? yield(node) : node
end
