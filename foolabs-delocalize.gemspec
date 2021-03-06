# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run the gemspec command
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{foolabs-delocalize}
  s.version = "0.2.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Clemens Kofler", "Marcin Raczkowski", "Fernando Migliorini Luiz\303\243o"]
  s.date = %q{2010-04-09}
  s.description = %q{Delocalize is a tool for parsing localized dates/times and numbers.}
  s.email = ["clemens@railway.at", "marcin.raczkowski@gmail.com", "fernandoluizao@gmail.com"]
  s.extra_rdoc_files = [
    "README"
  ]
  s.files = [
    "MIT-LICENSE",
     "README",
     "Rakefile",
     "VERSION",
     "init.rb",
     "lib/delocalize.rb",
     "lib/delocalize/i18n_ext.rb",
     "lib/delocalize/localized_date_time_parser.rb",
     "lib/delocalize/localized_numeric_parser.rb",
     "lib/delocalize/rails_ext.rb",
     "lib/delocalize/rails_ext/action_view.rb",
     "lib/delocalize/rails_ext/active_record.rb",
     "lib/delocalize/rails_ext/time_zone.rb",
     "lib/delocalize/rails_ext/validation.rb",
     "lib/delocalize/ruby_ext.rb",
     "lib/delocalize/ruby_ext/date.rb",
     "lib/delocalize/ruby_ext/datetime.rb",
     "lib/delocalize/ruby_ext/numeric.rb",
     "lib/delocalize/ruby_ext/time.rb",
     "tasks/distribution.rb",
     "tasks/documentation.rb",
     "tasks/testing.rb"
  ]
  s.homepage = %q{http://github.com/foolabs/delocalize}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.6}
  s.summary = %q{Localized date/time and number parsing}
  s.test_files = [
    "test/delocalize_test.rb",
     "test/rails_app/app/controllers/application_controller.rb",
     "test/rails_app/config/boot.rb",
     "test/rails_app/config/environment.rb",
     "test/rails_app/config/environments/test.rb",
     "test/rails_app/config/initializers/new_rails_defaults.rb",
     "test/rails_app/config/initializers/session_store.rb",
     "test/rails_app/config/routes.rb",
     "test/test_helper.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end

