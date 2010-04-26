# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run the gemspec command
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{snatch}
  s.version = "1.0.13"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["James Conroy-Finn"]
  s.date = %q{2010-04-26}
  s.description = %q{Simple site downloaded that wraps wget and converts PHP CSS files in to regular CSS files.}
  s.email = %q{james@logi.cl}
  s.extra_rdoc_files = [
    "LICENSE",
     "README.rdoc"
  ]
  s.files = [
    ".autotest",
     ".document",
     ".gitignore",
     "LICENSE",
     "README.rdoc",
     "Rakefile",
     "VERSION",
     "lib/extensions.rb",
     "lib/snatch.rb",
     "lib/snatch/clean.rb",
     "lib/snatch/clean/css.rb",
     "lib/snatch/clean/html.rb",
     "snatch.gemspec",
     "spec/snatch/clean/css_spec.rb",
     "spec/snatch/clean/html_spec.rb",
     "spec/snatch/clean_spec.rb",
     "spec/snatch_spec.rb",
     "spec/spec.opts",
     "spec/spec_helper.rb",
     "spec/support/matchers/nokogiri.rb",
     "xsl/pretty_print.xsl"
  ]
  s.homepage = %q{http://github.com/jcf/snatch}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.6}
  s.summary = %q{wget your site and replace any nasty PHP CSS files}
  s.test_files = [
    "spec/snatch/clean/css_spec.rb",
     "spec/snatch/clean/html_spec.rb",
     "spec/snatch/clean_spec.rb",
     "spec/snatch_spec.rb",
     "spec/spec_helper.rb",
     "spec/support/matchers/nokogiri.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<rspec>, [">= 1.2.9"])
      s.add_runtime_dependency(%q<nokogiri>, [">= 0"])
    else
      s.add_dependency(%q<rspec>, [">= 1.2.9"])
      s.add_dependency(%q<nokogiri>, [">= 0"])
    end
  else
    s.add_dependency(%q<rspec>, [">= 1.2.9"])
    s.add_dependency(%q<nokogiri>, [">= 0"])
  end
end

