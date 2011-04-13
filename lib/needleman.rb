#!/usr/bin/env ruby
# Needleman Wunsch Algorithm
# Returns edit distance

module Needleman
  class Wunsch
    def self.align(a, b)

      # Initialize a matrix, set row/column scores
      m = Matrice.new a.length, b.length, 0
      m.set_row 0, (0..a.length).to_a
      m.set_column 0, (0..b.length).to_a
    
      # Ruby doesn't like to iterate through a string, so make them arrays
      a, b = a.split(//), b.split(//)

      index = 0 # for banded alignment
      # Compute Distance Matrix
      a.each_with_index do |l, i|
        i += 1
        index += 1
        b.each_with_index do |r, j|
          j += 1
                
          # Compute score
          scores = []
          if l == r
            scores << m[i-1, j-1]
          else
            scores << m[i-1, j-1] + 1
          end
          scores << m[i-1, j] + 1
          scores << m[i, j-1] + 1
        
          # Fill in score
          m[i, j] = scores.min
        end
      end
      edit_distance = [m.get_row(-1).min, m.get_column(-1).min].min
      longest_length = [a.length, b.length].max.to_f
      score = (longest_length - edit_distance)/longest_length
      return score
    end
  end
end