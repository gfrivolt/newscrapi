require 'iconv'

class ContentMapping

  attr_reader :content_xpaths_list, :url_pattern_regexp, :iconv_to

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

  def iconv_from
    @iconv_from || ContentScrapper.guess_encoding
  end

  def suppose_encoding(encoding) @iconv_from = encoding end

  def convert_to(encoding) @iconv_to = encoding end

  def matches_url?(url)
    url =~ @url_pattern_regexp
  end

  def scrap_content(obj, content_scrapper = nil)
    doc = ContentScrapper.parse_page(obj)
    @content_xpaths_list.each do |content_xpath|
      content_section = doc.xpath(content_xpath)
      if content_section.count > 0
        content = content_section.to_a.join("\n")
        content = content_scrapper.clean_content(content) unless content_scrapper.nil?
        content = Iconv.conv(iconv_to, iconv_from, content) unless iconv_to.nil?
        return content 
      end
    end
    nil
  end
end

