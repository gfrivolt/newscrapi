require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "content_scrapper"
    gem.summary = "Gem for those who want to screen scrap only the content part of web pages, blogs or articles."
    gem.description = "If you want to cut only the content of pages, without any other part (like the menu, header, footer, commercials, etc.), you might find this gem very handy. A DSL is also defined for nifty definitions for your screen scrapping and sanitization."
    gem.email = "gyorgy.frivolt@gmail.com"
    gem.homepage = "http://github.com/fifigyuri/content_scrapper"
    gem.authors = ["Gyorgy Frivolt"]
    gem.add_development_dependency 'thoughtbot-shoulda', '>=2.10.2'
    gem.add_development_dependency 'mocha', '>=0.9.8'

    gem.add_dependency 'nokogiri', '>=1.4.1'
    gem.add_dependency 'chardet'
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

begin
  require 'rcov/rcovtask'
  Rcov::RcovTask.new do |test|
    test.libs << 'test'
    test.pattern = 'test/**/test_*.rb'
    test.verbose = true
  end
rescue LoadError
  task :rcov do
    abort "RCov is not available. In order to run rcov, you must: sudo gem install spicycode-rcov"
  end
end

task :test => :check_dependencies

task :default => :test

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "content_scrapper #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
