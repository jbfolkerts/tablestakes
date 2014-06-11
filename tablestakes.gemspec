Gem::Specification.new do |s|
    s.name      = 'tablestakes'
    s.version   = '0.8.0'
    s.date      = '2014-06-10'
    s.summary   = 'Implementation of in-memory Tables'
    s.description = 'A simple implementation of Tables, for use in summing, joining, slicing and dicing data tables'
    s.authors   = ['J.B. Folkerts']
    s.email     = 'jbfolkerts@gmail.com'
    s.homepage = %q{http://rubygems.org/gems/tablestakes}
    s.files     = ['lib/tablestakes.rb', 'README.md', ]
    s.test_files = ['test.tab','cities.txt','capitals.txt','capitals.sorted','spec/factories.rb', 'spec/table_spec.rb', 'spec/spec_helper.rb']
    s.rubygems_version = '2.0.14'
    s.license  = 'MIT'
end