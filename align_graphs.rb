require 'rgl/adjacency'
require 'set'

class Array
  def chunk n
    each_slice(n).reduce([]) {|x,y| x += [y] }
  end
end

a = [1, 2, 2, 3, 2, 4, 4, 6, 3, 5, 6, 5, 7, 8].chunk(2).collect{ |x| x.sort! }.to_set
b = [1, 2, 1, 3, 3, 4, 3, 5, 5, 6, 4, 5].chunk(2).collect{ |x| x.sort! }.to_set

x = {
  1 => 1,
  2 => 2,
  3 => 3,
  4 => 4,
  5 => 5,
  6 => 6
}

p a
p b
p a & b