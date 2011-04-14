#!/usr/bin/env ruby

Dir.glob('./lib/*.rb').each { |file| require file }

require 'progressbar'
require 'parallel'
require 'set'

CLUSTER_AT = 90
ALIGN_AT = 0.90
CUTOFF = 100 - CLUSTER_AT
LOG_CUTOFF = 1

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
    
    counts = Array.new
    clusters.each_key do |filename|
      $stderr.puts " - #{filename}"
      # Make counts matrix
      counts << clusters[filename][:counts]
    end
    
    # Normalize?
    $stderr.puts "Making distance matrices from counts!"
    matrices = Hash.new
    adjacency_matrix = Array.new
    [0, 1].each do |n|
      counts[n].each_key do |i|
        counts[n].each_key do |j|
          a, b = counts[0][i], counts[1][j]
          lr = Math.log(a/b.to_f, 2)
          if (lr > -LOG_CUTOFF) and (lr < LOG_CUTOFF) and (i != j)
            adjacency_matrix << [i, j]
          end
        end
      end
      matrices[n] = adjacency_matrix.flatten
    end
    
    p matrices
    
    # ALIGN SAMPLES    
    $stderr.puts "Align samples"
    set_a = clusters[clusters.keys[0]][:reps].values
    set_b = clusters[clusters.keys[1]][:reps].values
    scores_between_samples = pairwise_align set_a, set_b

    clusters[:both] = Hash.new
    clusters[:both][:scores] = scores_between_samples
        
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
    second = matrices[1]
    second.each_with_index do |v, i|
      second[i] = convert[v]
    end
    matrices[1] = second

    sets = Array.new
    first = matrices[0].chunk(2).collect{ |x| x.sort! }
    
    # Get rid of baddies
    second = matrices[1].chunk(2).delete_if{ |x| x.include? nil}.collect{ |x| x.sort! }
    
    # Fancy subgraph finding algorithm
    consensus = Graph.make_graph (first & second).flatten
    consensus.write_to_graphic_file
    `mv graph.dot out/consensus.dot`
    
    # Draw graphs
    matrices.each_key do |key|
      graph = Graph.make_graph matrices[key]
      puts "#{key}"
#      puts "#{graph.inspect}"
      graph.write_to_graphic_file
      `mv graph.dot out/#{File.basename(key.to_s)}.dot`
    end
    
    # Print FASTA file
    output = File.new(@options[:output], 'w')
    (first & second).flatten.each do |node|
      sequence = clusters.values[0][:reps][node]
      counts = clusters.values[0][:counts][node]
      output.write(">#{node}:#{counts}\n#{sequence}\n")
    end
    
  end
end

Phylograph.run!
