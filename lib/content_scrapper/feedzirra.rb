# feedzirra entries are extended by methods for scrapping content
require 'feedzirra/feed_entry_utilities'
require 'ruby-debug'

module Feedzirra
  module FeedEntryUtilities

    # Scrap the content based on the URL and the existing content and return it
    def scrap_content(scrapper = ContentScrapper.default, full_page = nil)
      scrapper.scrap_content(self.url, full_page = full_page) || self.content.to_s
    end

    # Scrap the content or use the existing one and change the feed entry
    def scrap_content!(scrapper = ContentScrapper.default, full_page = nil)
      self.content = scrap_content(scrapper, full_page = full_page)
    end
  end
end
