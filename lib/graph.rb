require 'rgl/adjacency'
require 'rgl/dot'

class Graph
  def self.make_graph(adjacency_matrix)
    RGL::AdjacencyGraph[*adjacency_matrix]
  end
  
  def self.align(a, b, c)
    
    # Match numbers in a & b using c
    a.each_edge do |edge|
      if c.has_vertex?
        
      end
    end
    # Align a & b
    
  end
end