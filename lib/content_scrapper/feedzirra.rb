# feedzirra entries are extended by methods for scrapping content
require 'feedzirra/feed_entry_utilities'

module Feedzirra
  module FeedEntryUtilities

    # Scrap the content based on the URL and the existing content and return it
    def scrap_content(scrapper)
      scrapper.scrap_content(self.url) || self.content.to_s
    end

    # Scrap the content or use the existing one and change the feed entry
    def scrap_content!(scrapper)
      content = scrap_content(scrapper)
    end
  end
end
