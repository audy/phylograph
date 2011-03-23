require 'rgl/adjacency'
require 'rgl/dot'

class Graph
  def self.make_graph(adjacency_matrix)
    RGL::DirectedAdjacencyGraph[*adjacency_matrix]
  end
end