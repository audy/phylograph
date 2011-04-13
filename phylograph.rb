#!/usr/bin/env ruby

Dir.glob('./lib/*.rb').each { |file| require file }

require 'progressbar'
require 'parallel'
require 'pp'

CLUSTER_AT = 80
ALIGN_AT = 0.90
CUTOFF = 5
BANDWIDTH = nil

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
    $scores = scores_between_samples
    
    clusters[:both] = Hash.new
    clusters[:both][:scores] = scores_between_samples
    
    @graphs = Hash.new
    @adjacency_matrices = Hash.new

    # Create graphs for Clusters
    @options[:filenames].each do |filename|
      p filename
      m = create_adjacency_matrix clusters[filename][:scores]
      graph = Graph.make_graph m
      p graph
      graph.write_to_graphic_file
      `mv graph.dot out/#{File.basename(filename)}.dot`
      @graphs[filename] = graph
      @adjacency_matrices[filename] = m
    end
    
    # Create graph between clusters (No Duplicates!)

    m = create_adjacency_matrix clusters[:both][:scores], nodup = true
    m = m.to_a

    pp clusters[:both][:scores]
    
    @graphs[:both] = Graph.make_graph m
    @graphs[:both].write_to_graphic_file
    `mv graph.dot out/both.dot`
      
    # Create hash to go from nodes in A to nodes in B:
    convert = Hash.new
    @graphs[:both].each_vertex do |vertex|
      puts vertex
      a, b = @graphs[:both].cycles_with_vertex(vertex)[0]
      convert[a] = b
      convert[b] = a
    end
    

    
    # ALIGN GRAPHS
    sets = Array.new
    
    # Add first graph
    m = @adjacency_matrices.values[0]
    m = m.chunk(2).collect{ |x| x.sort! }.to_set
    sets << m
    
    # Add second graph, convert first
    m = @adjacency_matrices.values[1]
    m = m.chunk(2).collect{ |x| x.sort! }
    new_m = Array.new
    m.each do |chunk|
      new_chunk = Array.new
      chunk.each do |v|
        v = convert[v] # What to do if it's not there?
        puts "#{v}, #{convert[v]}"
        new_chunk << v
      end
      new_m << new_chunk
    end
    m = new_m.to_set
    sets << m
    
    m = (sets[0] & sets[1]).to_a
    
    # OUTPUT
    puts "Consensus:"
    consensus_graph = Graph.make_graph m.flatten
    puts consensus_graph
    consensus_graph.write_to_graphic_file
    `mv graph.dot out/consensus.dot`
    
    out = File.new(@options[:output], 'w')
    consensus_graph.each_vertex do |vertex|
      out.write "> #{vertex}"
      out.write "#{clusters.first[1][:reps][vertex]}"
    end
    out.close

    clusters
  end
end

Phylograph.run!