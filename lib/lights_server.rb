Dir[File.join(File.dirname(__FILE__), '*/*.rb')].each { |fi| require_relative fi }
