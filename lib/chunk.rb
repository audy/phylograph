class Array
  def chunk n
    each_slice(n).reduce([]) {|x,y| x += [y] }
  end
end