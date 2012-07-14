$:.unshift(File.dirname(__FILE__))
require 'pldr'
map '/' do
  run Pldr
end
