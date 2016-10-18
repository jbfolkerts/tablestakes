# -*- encoding: utf-8 -*-
lib = File.expand_path('./lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

Gem::Specification.new do |s|
    s.name      = 'tablestakes'
    s.version   = '0.9.5'
    s.date      = '2016-10-18'
    s.summary   = 'Implementation of in-memory Tables'
    s.description = 'A simple implementation of Tables, for use in summing, joining, slicing and dicing data tables'
    s.authors   = ['J.B. Folkerts']
    s.email     = 'jbf@pentambic.com'
    s.homepage = %q{http://rubygems.org/gems/tablestakes}
    s.add_development_dependency "rspec", "~> 3.2"
    s.add_development_dependency "rspec-its", "~> 1.2"
    s.add_development_dependency "rspec-core", "~> 3.2"
    s.add_development_dependency "rspec-expectations", "~> 3.2"
    s.add_development_dependency "factory_girl", "~> 4.7"
    s.add_development_dependency "simplecov", "~> 0.9"
    s.add_development_dependency "coveralls", "~> 0.8"
    s.files     = Dir.glob("{lib,doc}/**/*") + ['README.md']
    s.test_files = ['test.tab','cities.txt','capitals.txt','capitals.sorted','spec/factories.rb', 'spec/table_spec.rb', 'spec/spec_helper.rb']
    s.rubygems_version = '2.4.6'
    s.license  = 'MIT'
end
