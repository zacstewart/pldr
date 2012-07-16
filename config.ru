$:.unshift(File.dirname(__FILE__))
require 'pldr'
map '/assets' do
  run Pldr.sprockets
end
map '/' do
  run Pldr
end
