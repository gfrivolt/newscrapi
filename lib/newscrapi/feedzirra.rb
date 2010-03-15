# feedzirra entries are extended by methods for scrapping content
require 'feedzirra/feed_entry_utilities'

module Feedzirra
  module FeedEntryUtilities

    # Scrap the content based on the URL and the existing content and return it
    def scrap_content(scrapper = Newscrapi::Scrapper.default, options = {})
      scrapper.scrap_content(self.url, options) || self.content.to_s
    end

    # Scrap the content or use the existing one and change the feed entry
    def scrap_content!(scrapper = Newscrapi::Scrapper.default, options = {})
      self.content = scrap_content(scrapper, options)
    end
  end
end
