
require 'open-uri'
require 'nokogiri'

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

  attr_reader :content_mappings

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

  def clean_content(content)
    @content_cleaner_block.nil? ? content : @content_cleaner_block.call(content)
  end

  def sanitize_tags(&sanitize_settings)
    @content_cleaner_block = lambda do |content|
      require 'sanitize'
      Sanitize.clean(content, sanitize_settings.call())
    end
  end

  def loofah_tags(scrap_type)
    @content_scrapper_block = lambda do |content|
      require 'loofah'
      Loofah.document(content).scrub!(scrap_type).to_s
    end
  end

  def scrap_content(url, options = {})
    content_mappings.each do | content_mapping |
      if content_mapping.matches_url?(url)
        return nil if content_mapping.content_xpaths_list.empty?
        begin
          doc = Nokogiri::HTML(options[:use_page] || Kernel.open(url))
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

