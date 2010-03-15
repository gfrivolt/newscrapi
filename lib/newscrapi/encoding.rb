
require 'rchardet'
require 'nokogiri'
require 'iconv'

module Newscrapi
  module Encoding

    def self.guess_html_encoding(obj)
      doc, page = parse_parameters_doc_page(obj)

      meta_encoding = doc.meta_encoding
      return meta_encoding unless meta_encoding.nil?
      CharDet.detect(page)['encoding']
    end

    def self.get_html_doc_with_changed_encoding(obj, encode_to)
      doc, page = parse_parameters_doc_page(obj)

      if encode_to
        guessed_encoding = guess_html_encoding(page)
        if guessed_encoding != encode_to
          doc = doc.serialize(:encoding => encode_to)
          page = doc.to_s
          return Nokogiri::HTML(page)
        end
      end
      doc
    end

    private

    def self.parse_parameters_doc_page(obj)
      if (obj.class == String)
        page = obj
        doc = Nokogiri::HTML(page)
      elsif (obj.class == Nokogiri::HTML::Document)
        doc = obj
        page = doc.to_s
      else raise Exception.new("Not supported type #{obj.class.to_s}") end
      return doc, page
    end
  end
end
