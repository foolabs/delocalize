begin
  require 'jeweler'
  Jeweler::Tasks.new do |s|
    s.name        = "foolabs-delocalize"
    s.summary     = "Localized date/time and number parsing"
    s.email       = ["clemens@railway.at", "marcin.raczkowski@gmail.com", "fernandoluizao@gmail.com"]
    s.homepage    = "http://github.com/foolabs/delocalize"
    s.description = "Delocalize is a tool for parsing localized dates/times and numbers."
    s.authors     = ["Clemens Kofler", "Marcin Raczkowski", "Fernando Migliorini Luizão"]
    s.files       =  FileList["init.rb",
                              "lib/**/*.rb",
                              "MIT-LICENSE",
                              "Rakefile",
                              "README",
                              "tasks/**/*.rb",
                              "VERSION"]
    s.test_files  = FileList["test/**/*.rb"]
  end
rescue LoadError
  puts "Jeweler, or one of its dependencies, is not available. Install it with: sudo gem install technicalpickles-jeweler -s http://gems.github.com"
end
