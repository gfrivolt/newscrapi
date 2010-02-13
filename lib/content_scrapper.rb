
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

  def sanitize_tags(settings)
    @sanitize_settings = settings
  end

  def scrap_content(url)
    content_mappings.each do | content_mapping |
      if content_mapping.matches_url?(url)
        return nil if content_mapping.content_xpaths_list.empty?
        begin
          doc = Nokogiri::HTML(Kernel.open(url))
          content = content_mapping.scrap_content(doc)
          return nil if content.nil?
          return Sanitize.clean(content, sanitize_settings)
        rescue Exception
          scrap_content_exception($!)
        end
      end
    end
    nil
  end

  def scrap_content_exception(exception)
  end
end
