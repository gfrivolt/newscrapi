
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

  attr_reader :content_mappings, :scrapping_exception_handler_block,
    :missing_url_matcher_handler_block, :missing_content_handler_block

  def self.parse_page(obj)
    return obj if obj.class == Nokogiri::HTML::Document
    Nokogiri::HTML(obj)
  end

  def self.guess_encoding(str)
    require 'rchardet'
    CharDet.detect(str)['encoding']
  end

  def initialize(scrapper_config_file = nil)
    @content_mappings = []
    config_file = scrapper_config_file || ContentScrapper.default_config_file
    self.instance_eval(File.read(config_file), config_file) unless config_file.nil?
  end

  def encode_to(encoding)
    @encode_to = encoding
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

  def matching_content_mapper(url)
    content_mappings.each { | content_mapping | return content_mapping if content_mapping.matches_url?(url) }
    nil
  end

  def scrap_content(url, options = {})
    if (content_mapping = matching_content_mapper(url)).nil?
      @missing_url_matcher_handler_block.call(url) unless @missing_url_matcher_handler_block.nil?
      return nil
    end
    return nil if content_mapping.content_xpaths_list.empty?
    begin
      doc = ContentScrapper.parse_page(options[:use_page] || Kernel.open(url))
      scrapped_content = content_mapping.scrap_content(doc, content_scrapper = self)
      @missing_content_handler_block.call(url) if !@missing_content_handler_block.nil? and scrapped_content.nil?
      return scrapped_content
    rescue Exception
      @scrapping_exception_handler_block.call($!, url) unless @scrapping_exception_handler_block.nil?
      return nil
    end
    nil
  end

  def rescue_scrapping(&block)
    @scrapping_exception_handler_block = block
  end

  def missing_url_matcher(&block)
    @missing_url_matcher_handler_block = block
  end

  def missing_content(&block)
    @missing_content_handler_block = block
  end

  def report_to_stderr
    rescue_scrapping do |exception, url|
      STDERR << "error occured during scrapping page #{url}\n"
      STDERR << "#{exception.message}\n"
      STDERR << exception.backtrace.join("\n")
    end

    missing_url_matcher do |url|
      STDERR << "missing matcher for #{url}\n"
    end

    missing_content do |url|
      STDERR << "empty content for #{url}\n"
    end
  end
end

