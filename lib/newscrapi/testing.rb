require 'newscrapi/scrapper'

class Newscrapi::Scrapper

  alias :old_initialize :initialize

  def initialize
    old_initialize
    testing_report_to_stderr
  end

  def testing_report_to_stderr
    rescue_scrapping do |exception, url|
#      extended_exception = Exception.new("error occured during scrapping page #{url}: #{exception.message}")
#      extended_exception.set_backtrace(exception.backtrace)
      raise exception #extended_exception
    end
  end
end
