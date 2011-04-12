require 'rgl/adjacency'

# Make Graphs
a = RGL::AdjacencyGraph[]
b = RGL::AdjacencyGraph[]
c = RGL::AdjacencyGraph[]

p a
p b
p c

# Using C, Match A with C
a.each_vertex do |v|
  puts v
  puts b.has_vertex? v
end