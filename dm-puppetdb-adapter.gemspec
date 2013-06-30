# -*- encoding: utf-8 -*-

Gem::Specification.new do |gem|
  gem.name        = "dm-puppetdb-adapter"
  gem.version     = %x{git describe --tags}.split('-')[0..1].join('.')
  gem.platform    = Gem::Platform::RUBY
  gem.authors     = ["Erik Dalén"]
  gem.email       = ["erik.gustav.dalen@gmail.com"]
  gem.homepage    = "https://github.com/dalen/dm-puppetdbadapter"
  gem.summary     = %q{PuppetDB adapter for DataMapper}
  gem.description = gem.summary
  gem.license     = 'MIT License (Expat)'

  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features,examples}/*`.split("\n")
  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.extra_rdoc_files = %w[LICENSE]
  gem.require_paths = [ "lib" ]

  gem.add_dependency 'json'
  gem.add_dependency 'puppet', '~> 3'
  gem.add_dependency 'dm-types'

  gem.add_development_dependency 'rake'
end
