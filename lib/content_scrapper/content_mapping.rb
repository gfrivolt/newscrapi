require 'iconv'

class ContentMapping

  attr_reader :content_xpaths_list, :url_pattern_regexp, :iconv_from, :iconv_to

  def initialize
    @content_xpaths_list = []
  end

  def url_pattern(pattern)
    @url_pattern_regexp = pattern
  end

  def content_at(content_xpath)
    @content_xpaths_list << content_xpath
  end

  def iconv(args)
    @iconv_from = args[:from]
    @iconv_to = args[:to]
  end

  def matches_url?(url)
    url =~ @url_pattern_regexp
  end

  def scrap_content(doc, content_scrapper = nil)
    @content_xpaths_list.each do |content_xpath|
      content_section = doc.xpath(content_xpath)
      content = content_section.to_a.join("\n")
      content = Sanitize.clean(content, content_scrapper.sanitize_settings) unless content_scrapper.nil?
      content = Iconv.iconv(to=iconv_to, from=iconv_from, content).join("\n") unless iconv_to.nil?
      return content if content_section.count > 0
    end
    nil
  end
end
