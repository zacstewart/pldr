require 'bundler'
require 'sprockets'
Bundler.require
require 'carrierwave/orm/activerecord'

set :database, ENV['DATABASE_URL']
set :logging, :true

CarrierWave.configure do |config|
  config.fog_credentials = {
    provider:               'AWS',
    aws_access_key_id:      ENV['AWS_ACCESS_KEY_ID'],
    aws_secret_access_key:  ENV['AWS_SECRET_ACCESS_KEY']
  }
  config.fog_directory = 'pldr'
  config.fog_attributes = {'Cache-Control'=>'max-age=315576000'}
end

class PhotoUploader < CarrierWave::Uploader::Base
  storage :fog
  def root; 'public'; end
  def filename; model.tiny + original_filename; end
end

class Photo < ActiveRecord::Base
  validate :tiny, :file, presence: true
  attr_accessible :tiny, :file
  mount_uploader :file, PhotoUploader
end

module AssetHelpers
  def asset_path(source)
    '/assets/' << settings.sprockets.find_asset(source).digest_path
  end
end

class Pldr < Sinatra::Base
  configure do
    set :root, File.dirname(__FILE__)
    set :sprockets, Sprockets::Environment.new(root)
    set :precompile, [ /\w+\.(?!js|css).+/, /application.(css|js)$/ ]
    set :assets_prefix, 'assets'
    set :assets_path, File.join(root, assets_prefix)
    sprockets.append_path(File.join(root, 'assets', 'stylesheets'))
    sprockets.context_class.instance_eval { include AssetHelpers }
  end
  
  helpers do
    include AssetHelpers
  end
  
  get '/' do
    photo = Photo.new
    slim :index, locals: {photo: photo}
  end
  
  post '/' do
    photo = Photo.new params[:photo]
    while photo.tiny.blank? || Photo.find_by_tiny(photo.tiny) 
      photo.tiny = rand(36**3).to_s(36)
    end

    if photo.save
      status 201
      redirect "/#{photo.tiny}"
    else
      status 400
      slim :index, locals: {photo: photo}
    end
  end

  get '/:tiny' do
    photo = Photo.find_by_tiny params[:tiny]
    slim :show, locals: {photo: photo}
  end
end
