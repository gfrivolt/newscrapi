require 'newscrapi/scrapper'
require 'iconv'

class Newscrapi::Mapping

  attr_reader :content_xpaths_list, :url_pattern_regexp

  def initialize
    @content_xpaths_list = []
  end

  def url_pattern(pattern)
    @url_pattern_regexp = pattern.class == String ?
      Regexp.compile("^#{Regexp.escape(pattern).gsub('\*','.*')}$") : pattern
  end

  def content_at(content_xpath)
    @content_xpaths_list << content_xpath
  end

  def iconv(args)
    suppose_encoding(args[:from])
    convert_to(args[:to])
  end

=begin
  def suppose_encoding(encoding = nil)
    return @supposed_encoding if encoding.nil?
    @supposed_encoding = encoding
  end
=end

  def matches_url?(url)
    url =~ @url_pattern_regexp
  end

  def scrap_content(obj, content_scrapper = nil)
    doc = Newscrapi::Scrapper.parse_page(obj)
    @content_xpaths_list.each do |content_xpath|
      content_section = doc.xpath(content_xpath)
      if content_section.count > 0
        content = content_section.to_a.join("\n")
        content = content_scrapper.clean_content(content) unless content_scrapper.nil?
        return content
      end
    end
    nil
  end
end

