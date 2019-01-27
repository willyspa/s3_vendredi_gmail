require 'nokogiri'
require 'rubygems'
require 'open-uri'
require 'pry'
require 'csv'
require 'google/apis/gmail_v1'
require 'googleauth'
require 'googleauth/stores/file_token_store'
require 'fileutils'
require 'mime'
include MIME



$:.unshift File.expand_path('./../lib/views', __FILE__)
#require 'views/view.rb'
$:.unshift File.expand_path('./../lib', __FILE__)

require 'scrapper'

#Scrapper.new.scrap
Scrapper.new.readcsv
Scrapper.new.mailing
