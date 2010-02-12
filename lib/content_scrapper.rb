
require 'open-uri'
require 'nokogiri'
require 'sanitize'

class ContentScrapper

  class << self
    attr_accessor :default_config_file, :default
    default_config_file = "#{File.dirname(__FILE__)}/../config/content_scrapper.yml"

    def create_new_default(*args)
      self.default = self.new(*args)
    end
  end

  def set_as_default
    ContentScrapper.default = self
  end

  attr_accessor :content_mappings, :sanitize_settings

  def initialize(scrapper_config_file = nil)
    scrapper_config_file ||= ContentScrapper.default_config_file
    config_file =  scrapper_config_file
    scrapper_config = YAML::load(File.open(config_file))
    @content_mappings = scrapper_config['content_mappings']
    @sanitize_settings = scrapper_config['sanitize_settings']
  end

  def scrap_content(url)
    content_mappings.each do | regexp_url, xpath_to_contents |
      if url =~ %r/#{regexp_url}/ and !(xpath_to_contents.nil? || xpath_to_contents.empty?)
        begin
          feeditem_page = Kernel.open(url)
          xpath_to_contents.each do |supposed_content_xpath|
            content_section = Nokogiri::HTML(feeditem_page).xpath(supposed_content_xpath)
            if content_section.count > 0
              content_section = content_section.to_a.join("\n")
              return Sanitize.clean(content_section, sanitize_settings)
            end
            feeditem_page.rewind
          end
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
