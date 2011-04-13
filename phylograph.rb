#!/usr/bin/env ruby

Dir.glob('./lib/*.rb').each { |file| require file }

require 'progressbar'
require 'parallel'
require 'pp'

CLUSTER_AT = 80
ALIGN_AT = 0.8
CUTOFF = 5

class Phylograph
  def self.run!
    parse_arguments
#    @options = {:filenames=>["data/short_a.fasta", "data/short_b.fasta"], :output=>"test_output.txt"}
    
    # COMPUTE CLUSTERS
    
    $stderr.puts "Computing Clusters"
    clusters = Hash.new
    
    @options[:filenames].each do |filename|
      $stderr.puts " - #{filename}"
      clusters[filename] = Cluster.compute_clusters CLUSTER_AT, filename
      puts "Got #{clusters[filename][:reps].length} clusters #{CLUSTER_AT}%"
    end

    # ALIGN CLUSTERS
    $stderr.puts "Interior Alignments"
    clusters.each_key do |filename|     
      $stderr.puts " - #{filename}" 
      sequences = clusters[filename][:reps].values
      clusters[filename][:scores] = pairwise_align sequences, sequences
    end
    
    # ALIGN SAMPLES    
    $stderr.puts "Align samples"
    set_a = clusters[clusters.keys[0]][:reps].values
    set_b = clusters[clusters.keys[1]][:reps].values
    scores_between_samples = pairwise_align set_a, set_b
    
    clusters[:both] = Hash.new
    clusters[:both][:scores] = scores_between_samples
    
    @options[:filenames].each do |filename|
      matrix = create_adjacency_matrix clusters[filename][:scores], nodup=false
      puts matrix.inspect
    end
    
    matrix = create_adjacency_matrix clusters[:both][:scores], nodup=true
    puts matrix.inspect
    
  end
end

Phylograph.run!