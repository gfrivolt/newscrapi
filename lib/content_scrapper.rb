
require 'open-uri'
require 'nokogiri'
require 'sanitize'

require 'content_scrapper/content_mapping'

class ContentScrapper

  class << self
    attr_accessor :default_config_file, :default
    default_config_file = "#{File.dirname(__FILE__)}/../config/content_scrapper.rb"

    def create_new_default(*args)
      self.default = self.new(*args)
    end
  end

  def set_as_default
    ContentScrapper.default = self
  end

  attr_accessor :content_mappings, :sanitize_settings

  def initialize(scrapper_config_file = nil)
    @content_mappings = []
    config_file = scrapper_config_file || ContentScrapper.default_config_file
    self.instance_eval(File.read(config_file), config_file) unless config_file.nil?
  end

  def content_mapping(&block)
    new_mapping = ContentMapping.new
    new_mapping.instance_eval(&block)
    @content_mappings << new_mapping
  end

  def sanitize_tags(&block)
    @sanitize_settings = block.call()
  end

  def scrap_content(url)
    content_mappings.each do | content_mapping |
      if content_mapping.matches_url?(url)
        return nil if content_mapping.content_xpaths_list.empty?
        begin
          doc = Nokogiri::HTML(Kernel.open(url))
          return content_mapping.scrap_content(doc, content_scrapper = self)
        rescue Exception
          @scrapping_exception_handler_block.call($!) unless @scrapping_exception_handler_block.nil?
          return nil
        end
      end
    end
    @missing_url_matcher_handler_block.call(url) unless @missing_url_matcher_handler_block.nil?
    nil
  end

  def rescue_scrapping(&block)
    @scrapping_exception_handler_block = block
  end

  def missing_url_matcher(&block)
    @missing_url_matcher_handler_block = block
  end
end

