require 'helper'
require 'mocha'

class TestContentScrapper < Test::Unit::TestCase

  ContentScrapper.default_config_file = "#{File.dirname(__FILE__)}/content_scrapper.yml"

  context "on common setting" do
    setup { @scrapper = ContentScrapper.new }

    context "for known sources with expected content scrapping" do
      setup do
        pretty_content = File.open("#{File.dirname(__FILE__)}/test_pages/pretty.html").read 
        stringio = StringIO.new(pretty_content)
        Kernel.expects(:open).returns(stringio)
        @entry_content = @scrapper.scrap_content('http://www.pretty.url/fsdsd')
      end
      should("identify the content") do
        assert_match(%r{<p><strong>This is a strong text</strong></p>}, @entry_content)
      end
    end

    context "for known infosources with unexpected content scrapping" do
      setup do
        ugly_content = File.open("#{File.dirname(__FILE__)}/test_pages/ugly.html").read
        stringio = StringIO.new(ugly_content)
        Kernel.expects(:open).returns(stringio)
        @entry_content = @scrapper.scrap_content('http://www.pretty.url/hsdae')
      end
      should("return nil") { assert_nil @entry_content }
    end

    context "for unknown infosources" do
      setup { @entry_content = @scrapper.scrap_content('http://www.unknown.url/hsdae') }
      should("return nil") { assert_nil @entry_content }
    end

    context "on scrapping with feedzirra" do
      setup do
        require 'content_scrapper/feedzirra'
        require 'sax-machine'
        require 'feedzirra/parser/rss_entry'
        require 'feedzirra/parser/atom_entry'
      end

      context "feed entry with not parsable remote content, but with feed content set" do
        setup do
          @feed_entries = [ Feedzirra::Parser::RSSEntry.new, Feedzirra::Parser::AtomEntry.new ]
          @feed_entries.each do |feed_entry|
            feed_entry.url = 'http://www.unknown.url/wedhsf'
            feed_entry.content = 'Pretty well written content is this.'
          end
          Kernel.expects(:open).with('http://www.unknown.url/wedhsf').never
        end
        should("return the original feed content") do
          @feed_entries.each do |feed_entry|
            assert_equal 'Pretty well written content is this.', feed_entry.scrap_content(@scrapper)
            feed_entry.scrap_content!(@scrapper)
            assert_equal 'Pretty well written content is this.', feed_entry.content
          end
        end
      end
    end
  end

  context "on setting default content scrapper" do
    setup { @scrapper = ContentScrapper.create_new_default }
    should "set the default to the recently created" do
      assert_equal @scrapper, ContentScrapper.default
    end
    context "when changing default content scrapper" do
      setup { @new_scrapper = ContentScrapper.new.set_as_default }
      should "change the default to the new content scrapper" do
        assert_equal @new_scrapper, ContentScrapper.default
      end
    end
  end
end
