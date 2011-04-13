#!/usr/bin/env ruby

Dir.glob('./lib/*.rb').each { |file| require file }

require 'progressbar'
require 'parallel'

CLUSTER_AT = 80
ALIGN_AT = 0.90
CUTOFF = 5
BANDWIDTH = nil

class Phylograph
  def self.run!
    parse_arguments

    # COMPUTE CLUSTERS
    
    $stderr.puts "Computing Clusters"
    clusters = Hash.new
    
    @options[:filenames].each do |filename|
      $stderr.puts " - #{filename}"
      clusters[filename] = Cluster.compute_clusters CLUSTER_AT, filename
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
    $scores = scores_between_samples
    
    clusters[:both] = Hash.new
    clusters[:both][:scores] = scores_between_samples
    
    @graphs = Hash.new
    @adjacency_matrices = Hash.new

    # Create graphs for Clusters
    @options[:filenames].each do |filename|
      m = create_adjacency_matrix clusters[filename][:scores]
      graph = Graph.make_graph m
      @graphs[filename] = graph
      graph.write_to_graphic_file
      `mv graph.dot #{File.basename(filename)}.dot`
      @adjacency_matrices[filename] = m
    end
    
    # Create graph between clusters (No Duplicates!)
    m = create_adjacency_matrix clusters[:both][:scores], nodup = true
    @graphs[:both] = Graph.make_graph m
    @adjacency_matrices[:both] = m # Don't really need this...
      
    # Create hash to go from nodes in A to nodes in B:
    convert = Hash.new
    @graphs[:both].each_vertex do |vertex|
      a, b = @graphs[:both].cycles_with_vertex(vertex)[0]
      convert[a] = b
      convert[b] = a
    end
    
    # For Debugging
    $convert = convert    
    $clusters = clusters
    
    # Build Consensus Graph
    sets = Array.new

    @adjacency_matrices.values.each do |m|
      m = m.chunk(2).collect{ |x| x.sort! }.to_set
      sets << m
    end
    
    # This is the consensus graph
    m = (sets[0] & sets[1]).to_a
    
    # Make a real graph
    g = Graph.make_graph m.flatten
    p g
    g.write_to_graphic_file
    `mv graph.dot both.dot`
    
    # Print it?
    # Identify sequences?
  end
end

Phylograph.run!