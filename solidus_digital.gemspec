Gem::Specification.new do |s|
  s.platform     = Gem::Platform::RUBY
  s.name         = 'solidus_digital'
  s.version      = '1.0.1'
  s.summary      = 'Digital download functionality for solidus'
  s.description  = 'Digital download functionality for solidus'
  s.authors      = ['taktsoft', 'A. Trakowski']
  s.email        = ['trakowski@taktsoft.com']
  s.homepage     = 'https://www.taktsoft.com'
  s.files        = `git ls-files`.split("\n")
  s.test_files   = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.require_path = 'lib'
  s.requirements << 'none'
  s.required_ruby_version = '>= 2.1.0'

  solidus_version = '>= 2.0.0', '< 3.0'
  s.add_dependency 'solidus_api', solidus_version
  s.add_dependency 'solidus_backend', solidus_version
  s.add_dependency 'solidus_core', solidus_version
  s.add_dependency 'solidus_frontend'

  # test suite
  s.add_development_dependency 'shoulda-matchers'
  s.add_development_dependency 'capybara'
  s.add_development_dependency 'coffee-script'
  s.add_development_dependency 'factory_girl_rails'
  s.add_development_dependency 'rspec-rails'
  s.add_development_dependency 'rspec-activemodel-mocks'
  s.add_development_dependency 'sass-rails'
  s.add_development_dependency 'sqlite3'
  s.add_development_dependency 'ffaker'
  s.add_development_dependency 'database_cleaner'
  s.add_development_dependency 'simplecov'
  s.add_development_dependency 'rb-fsevent'
  s.add_development_dependency 'growl'
  s.add_development_dependency 'pg'
  s.add_development_dependency 'mysql2'
end
