require 'rake/clean'

CLEAN.include('cd-hit-v4.3-2010-10-25', 'cd-hit-v4.3-2010-10-25.tgz')
CLOBBER.include('lib/cd-hit-est')

task :default do
  sh 'mkdir -p out'
  sh "rm -f out/*"
  sh './phylograph.rb -r data/pa.fa,data/paa.fa \
     -o out/sequences.fa'
  Dir.glob('out/*.dot') do |file|
    sh "python make_graphs.py #{file} > #{file}.fix"
    sh "dot -Tpdf #{file}.fix > #{file}.pdf"
  end
  sh "open out/*.pdf"
end

task :test do
  puts "Testing"
  sh 'ruby lib/needleman.rb'
end

namespace :cdhit do
  task :install => 'lib/cd-hit-est' do
  end
  
  file 'cd-hit-v4.3-2010-10-25' do
    sh 'tar -zxvf cd-hit-v4.3-2010-10-25.tgz'
  end

  file 'cd-hit-v4.3-2010-10-25.tgz' do
    sh 'curl -LO http://www.bioinformatics.org/download.php/cd-hit/cd-hit-v4.3-2010-10-25.tgz'
  end
  
  file 'cd-hit-v4.3-2010-10-25' => 'cd-hit-v4.3-2010-10-25.tgz' do
    cd 'cd-hit-v4.3-2010-10-25'
    sh 'make openmp=yes'
    cd '..'
  end
  
  file 'lib/cd-hit-est' => 'cd-hit-v4.3-2010-10-25' do
    sh 'mv cd-hit-v4.3-2010-10-25/cd-hit-est lib/cd-hit-est'
  end
end
