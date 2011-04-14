# Stuff I don't want in the executable
require 'optparse'

class Phylograph
  
  # CREATE ADJACENCY MATRICES
  def self.create_adjacency_matrix(scores, nodup=true)
    matrix = Array.new
    scores.each_with_index do |row, i|
      max, best = -1, 0
      row.each_with_index do |score, j|
        if (score > max)
          if nodup and (i != j)
            max, best = score, j
          elsif !nodup
            max, best = score, j
          end
        end
      end
      if max > 0
        matrix << [i, best] #unless matrix.flatten.include? best
      end
    end
    matrix.flatten
  end
    
  def self.pairwise_align(set_a, set_b)
    combinations = set_a.product(set_b)

    matrices = Array.new
    progress = ProgressBar.new 'Aligning', combinations.length
    distance_matrix = Array.new
    
    # add more stuff to skip over obviously bad pairs,
    # ie nucleotide composition.

    scores = Parallel.map(combinations) do |a, b|  
      score =
        if (a.length - b.length).abs < CUTOFF
          score = Needleman::Wunsch.align a, b
          if score > ALIGN_AT
            score
          else
            -1
          end
        else
          -1
        end
      progress.inc
      score
    end
    progress.finish
    # Double-check this part.
    scores.each_slice(set_a.length).to_a
  end

  def self.parse_arguments
    @options = Hash.new    
    optparse = OptionParser.new do |opts|
      opts.banner = "PhyloGraph\nAustin G. Davis-Richardson\n\n"
      
      opts.on '-h', '--help', 'display this message' do |o|
        if o
          puts optparse
          exit
        end
      end
      
      opts.on '-r', '--reads a,b', Array, 'specify fasta files' do |o|
        @options[:filenames] = o
      end
      
      opts.on '-o', '--output prefix', 'specify output prefix' do
        |o| @options[:output] = o
      end
    end
    optparse.parse!
  end
end