
module TestContentScrapper

  def initialize
    super
    testing_report_to_stderr
  end

  def testing_report_to_stderr
    rescue_scrapping do |exception, url|
      STDERR << "error occured during scrapping page #{url}\n"
      STDERR << "#{exception.message}\n"
      STDERR << exception.backtrace.join("\n")
    end
  end
end
