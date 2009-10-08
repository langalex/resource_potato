require 'rake'
require 'spec/rake/spectask'
require 'rake/rdoctask'

task :default => :spec

desc "Run all specs"
Spec::Rake::SpecTask.new(:spec) do |t|
  t.spec_opts = ['--color']
  t.spec_files = FileList['spec/**_spec.rb']
end
