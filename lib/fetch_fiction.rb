# coding: utf-8
require 'bundler/setup'
require 'logger'
require 'sequel'
require 'sidekiq'
require 'pry'
module FetchFiction
  $logger = Logger.new($stdout)
  #$logger.level = Logger::INFO

  # connect database
  DB = Sequel.connect('sqlite://db/xiaoshuo.db', :loggers => [Logger.new('log/db.log')])
  # require database model
  Dir.glob "./lib/fetch_fiction/*/*.rb" do |f|
    require f
  end
end
