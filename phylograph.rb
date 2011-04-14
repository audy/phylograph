#!/usr/bin/env ruby

Dir.glob('./lib/*.rb').each { |file| require file }

require 'progressbar'
require 'parallel'
require 'set'

CLUSTER_AT = 95
ALIGN_AT = 0.96
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
    
    matrices = Hash.new
    
    @options[:filenames].each do |filename|
      matrix = create_adjacency_matrix clusters[filename][:scores], nodup=true
      matrices[filename] = matrix
    end
    
    matrix = create_adjacency_matrix clusters[:both][:scores], nodup=false
    matrices[:both] = matrix
  
    
    # Make translation hash
    convert = Hash.new
    matrices[:both].chunk(2).each do |i, j|
      convert[i] = j
      convert[j] = i
    end
    
    # Make consensus graph
    # Convert graph B to graph A names
    second = matrices[@options[:filenames][1]]
    second.each_with_index do |v, i|
      second[i] = convert[v]
    end
    matrices[@options[:filenames][1]] = second

    sets = Array.new
    first = matrices[@options[:filenames][0]].chunk(2).collect{ |x| x.sort! }
    
    # Get rid of baddies
    second.chunk(2).delete_if{ |x| x.include? nil }
    second = matrices[@options[:filenames][1]].chunk(2).collect{ |x| x.sort! }
    
    # Fancy subgraph finding algorithm
    consensus =  Graph.make_graph (first & second).flatten
    consensus.write_to_graphic_file
    `mv graph.dot out/consensus.dot`
    
    # Draw graphs
    matrices.each_key do |key|
      graph = Graph.make_graph matrices[key]
      puts "#{key}"
      puts "#{graph.inspect}"
      graph.write_to_graphic_file
      `mv graph.dot out/#{File.basename(key.to_s)}.dot`
    end
    
  end
end

Phylograph.run!