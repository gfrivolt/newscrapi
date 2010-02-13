
class ContentMapping

  attr_reader :content_xpaths_list, :url_pattern_regexp

  def initialize
    @content_xpaths_list = []
  end

  def url_pattern(pattern)
    @url_pattern_regexp = pattern
  end

  def content_at(content_xpath)
    @content_xpaths_list << content_xpath
  end

  def matches_url?(url)
    url =~ @url_pattern_regexp
  end

  def scrap_content(doc)
    @content_xpaths_list.each do |content_xpath|
      content_section = doc.xpath(content_xpath)
      return content_section.to_a.join("\n") if content_section.count > 0
    end
    nil
  end
end
